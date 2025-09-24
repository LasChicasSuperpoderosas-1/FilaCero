//
//  APIClient.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import Foundation

struct API {
    static let base = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207")!
}

enum APIError: LocalizedError {
    case badURL
    case invalidResponse
    case http(Int, String?)
    case decoding(String)
    
    var errorDescription: String? {
        switch self {
        case .badURL: return "URL inválida"
        case .invalidResponse: return "Respuesta inválida del servidor"
        case .http(let code, let msg): return msg ?? "Error HTTP \(code)"
        case .decoding(let msg): return "Error decodificando: \(msg)"
        }
    }
}

struct APIClient {
    static let shared = APIClient()
    private init() {}

    // ---------- Ventanillas ----------
    func fetchVentanillas(activas: Bool? = nil) async throws -> [Ventanilla] {
        var comp = URLComponents(url: API.base.appendingPathComponent("/ventanillas"),
                                 resolvingAgainstBaseURL: false)!
        if let activas {
            comp.queryItems = [URLQueryItem(name: "activa", value: activas ? "true" : "false")]
        }
        guard let url = comp.url else { throw APIError.badURL }

        var req = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringLocalCacheData,
                             timeoutInterval: 15)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw APIError.http(http.statusCode, nil) }

        let decoder = JSONDecoder()
        do {
            let envelope = try decoder.decode(VentanillasEnvelope.self, from: data)
            return envelope.ventanillas
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }

    // ---------- Login ----------
    func login(correo: String, password: String) async throws -> LoginResponse {
        let url = API.base.appendingPathComponent("/auth/login")
        var req = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringLocalCacheData,
                             timeoutInterval: 15)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let body = ["correo": correo, "password": password]
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }

        let decoder = JSONDecoder()
        if (200..<300).contains(http.statusCode) {
            do { return try decoder.decode(LoginResponse.self, from: data) }
            catch { throw APIError.decoding(error.localizedDescription) }
        } else {
            if let lr = try? decoder.decode(LoginResponse.self, from: data) {
                throw APIError.http(http.statusCode, lr.msg)
            }
            throw APIError.http(http.statusCode, nil)
        }
    }
}

