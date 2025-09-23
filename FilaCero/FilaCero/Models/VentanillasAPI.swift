//
//  VentanillasAPI.swift
//  FilaCero
//
//  Created by Alumno on 22/09/25.
//

import Foundation

struct VentanillasAPI {
    // ⚠️ Cambia por tu URL real
    static let baseURL = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207/ventanillas")!

    static func fetchAll() async throws -> [Ventanilla] {
        var req = URLRequest(url: baseURL)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        // Si usas token: req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
            let msg = String(data: data, encoding: .utf8) ?? "Respuesta inválida"
            throw NSError(domain: "API", code: code,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP \(code): \(msg)"])
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        // Si tu API regresa un array directo:
        return try decoder.decode([Ventanilla].self, from: data)

        // Si regresa { "data": [...] } usa:
        // struct Envelope: Codable { let data: [Ventanilla] }
        // return try decoder.decode(Envelope.self, from: data).data
    }
}

