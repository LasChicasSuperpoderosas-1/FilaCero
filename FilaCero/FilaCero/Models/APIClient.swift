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

enum APIError: Error {
    case badURL
    case invalidResponse
    case http(Int)
}

struct APIClient {
    static let shared = APIClient()
    private init() {}

    func fetchVentanillas(activas: Bool? = nil) async throws -> [Ventanilla] {
        var comp = URLComponents(url: API.base.appendingPathComponent("/ventanillas"), resolvingAgainstBaseURL: false)!
        if let activas {
            comp.queryItems = [URLQueryItem(name: "activa", value: activas ? "true" : "false")]
        }
        guard let url = comp.url else { throw APIError.badURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw APIError.http(http.statusCode) }

        let decoder = JSONDecoder()
        let envelope = try decoder.decode(VentanillasEnvelope.self, from: data)
        return envelope.ventanillas
    }
}

