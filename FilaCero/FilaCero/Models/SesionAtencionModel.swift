//
//  SesionAtencionModel.swift
//  FilaCero
//
//  Created by Marco de la Puente on 25/09/25.
//

import Foundation

struct OpenSessionResponse: Decodable {
    let ok: Bool?
    let mensaje: String?
}


enum APIErrorVentanilla: Error, LocalizedError {
    case badURL
    case http(Int, OpenSessionResponse?)
    case noData
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .badURL: return "URL inválida."
        case .http(let code, let payload):
            let msg = payload?.mensaje ?? "Error HTTP \(code)."
            return msg
        case .noData: return "Respuesta vacía del servidor."
        case .decoding(let err): return "No se pudo leer la respuesta: \(err.localizedDescription)"
        }
    }
}

enum APICallVentanilla {

    static let baseURL = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207")!

    static func abrirSesion(ventanilleroId: Int) async throws -> OpenSessionResponse {
        guard let url = URL(string: "/sesiones/abrir", relativeTo: baseURL) else {
            throw APIError.badURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["ventanillero_id": ventanilleroId]
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        guard let http = resp as? HTTPURLResponse else { throw APIErrorVentanilla.noData }

        let decoded: OpenSessionResponse? = try? JSONDecoder().decode(OpenSessionResponse.self, from: data)
        
        guard (200...299).contains(http.statusCode) else {
            throw APIErrorVentanilla.http(http.statusCode, decoded)
        }

        return decoded ?? OpenSessionResponse(ok: nil, mensaje: nil)
        
    }
}



