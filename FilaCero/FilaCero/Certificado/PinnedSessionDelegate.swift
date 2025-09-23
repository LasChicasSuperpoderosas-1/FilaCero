import Foundation
import Security

final class PinnedSessionDelegate: NSObject, URLSessionDelegate {
    static let shared = PinnedSessionDelegate()

    // Nombre del .cer dentro del bundle (sin extensión)
    private var certName: String = "mi_certificado"
    private var certExt:  String = "cer"

    /// Llama esto una vez (en App.init o antes del primer request)
    func configure(certName: String, ext: String = "cer") {
        self.certName = certName
        self.certExt  = ext
    }

    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let serverCert  = SecTrustCopyCertificateChain(serverTrust)
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // 1) Verifica que la cadena sea válida según el sistema
        var trustError: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &trustError) else {
            // Certificado/host/cadena inválidos
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 2) Toma el cert presentado por el server (leaf)
        let serverData = SecCertificateCopyData(serverCert as! SecCertificate) as Data

        // 3) Carga tu .cer del bundle (DEBE ser el leaf del host)
        guard let localURL  = Bundle.main.url(forResource: certName, withExtension: certExt),
              let localData = try? Data(contentsOf: localURL)
        else {
            #if DEBUG
            print("PinnedSessionDelegate: no se encontró \(certName).\(certExt) en el bundle")
            #endif
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 4) Pinning por certificado (igualdad binaria)
        if serverData == localData {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            #if DEBUG
            print("PinnedSessionDelegate: mismatch de certificado (no coincide con el leaf del server)")
            #endif
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
