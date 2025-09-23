import Foundation

// DTOs
struct VentanillaHabDesRequest: Codable { let activa: Bool }

struct VentanillaHabDesResponse: Codable {
    let idVentanilla: Int
    let codigoVentanilla: String
    let activa: Bool

    enum CodingKeys: String, CodingKey {
        case idVentanilla     = "id_ventanilla"
        case codigoVentanilla = "codigo_ventanilla"
        case activa
    }

    // ✅ Soporta true/false y 1/0
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        idVentanilla = try c.decode(Int.self, forKey: .idVentanilla)
        codigoVentanilla = try c.decode(String.self, forKey: .codigoVentanilla)

        // intenta Bool directo
        if let b = try? c.decode(Bool.self, forKey: .activa) {
            activa = b
        } else if let n = try? c.decode(Int.self, forKey: .activa) {
            activa = (n != 0)
        } else if let s = try? c.decode(String.self, forKey: .activa) {
            // por si algún backend manda "1"/"0" o "true"/"false"
            let lower = s.lowercased()
            if lower == "true" || lower == "1" { activa = true }
            else if lower == "false" || lower == "0" { activa = false }
            else {
                throw DecodingError.dataCorruptedError(forKey: .activa, in: c, debugDescription: "Formato desconocido para 'activa'")
            }
        } else {
            throw DecodingError.dataCorruptedError(forKey: .activa, in: c, debugDescription: "No se pudo decodificar 'activa'")
        }
    }
}

enum VentanillaHabDesAPI {
    static var baseURL: String = "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207"
    static var bearerToken: String? = nil

    // Llama esto una vez al arrancar (usa el nombre del .cer sin extensión)
    static func configurePin(certName: String, ext: String = "cer") {
        PinnedSessionDelegate.shared.configure(certName: certName, ext: ext)
    }

    // ✅ PUT /ventanillas/{id}/estado con pinning
    static func cambiarEstadoPinned(id: Int, activa: Bool) async throws -> VentanillaHabDesResponse {
        let url = URL(string: "\(baseURL)/ventanillas/\(id)/estado")!
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let t = bearerToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        req.httpBody = try JSONEncoder().encode(VentanillaHabDesRequest(activa: activa))
        req.timeoutInterval = 20

        let session = URLSession(configuration: .default,
                                 delegate: PinnedSessionDelegate.shared,
                                 delegateQueue: nil)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
            let body = String(data: data, encoding: .utf8) ?? "(sin cuerpo)"
            throw NSError(domain: "API", code: code,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP \(code): \(body)"])
        }
        return try JSONDecoder().decode(VentanillaHabDesResponse.self, from: data)
    }
}
