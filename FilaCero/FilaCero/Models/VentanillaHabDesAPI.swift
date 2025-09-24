import Foundation

enum VentanillaAPIError: Error {
    case badStatus(Int)
    case invalidURL
    case noData
    case noHTTP        // ← agrega este
}

enum VentanillaHabDesAPI {
    static var session: URLSession = .shared
    static let base = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207")!

    /// Devuelve el estado final (true/false). Si el server no manda JSON, regresa `activaEnviada`.
    static func cambiarEstado(ventanillaId: Int, activa activaEnviada: Bool) async throws -> Bool {
        var url = base
        url.append(path: "/vetnanillaHabDes/\(ventanillaId)") // según tu /apidocs

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try JSONEncoder().encode(["activa": activaEnviada])

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw VentanillaAPIError.noHTTP }

        // Log útil para terminal
        print("⇦ HTTP \(http.statusCode) \(req.url!.absoluteString)")
        if let s = String(data: data, encoding: .utf8), !s.isEmpty { print("Body: \(s)") }

        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<sin cuerpo>"
            throw NSError(domain: "HTTPError", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
        }

        // Si el server manda JSON con "activa", úsalo; si no, conserva lo enviado
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let activaSrv = obj["activa"] {
            if let b = activaSrv as? Bool { return b }
            if let i = activaSrv as? Int  { return i != 0 }
            if let s = activaSrv as? String { return s == "1" || s.lowercased() == "true" }
        }
        return activaEnviada
    }
}
