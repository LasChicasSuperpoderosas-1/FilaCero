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


private struct LogoutRequest: Encodable {
    let id_usuario: Int
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
    
    //--------- Logout -----------
    func logout(userId: Int, session: URLSession = .shared) async throws {
            let url = API.base.appendingPathComponent("/auth/logout")
            var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json", forHTTPHeaderField: "Accept")

            let body = LogoutRequest(id_usuario: userId)
            req.httpBody = try JSONEncoder().encode(body)

            let (_, resp) = try await session.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard http.statusCode == 204 else { throw APIError.http(http.statusCode, nil) }
        }
    
    // ---------- HorarioAdmin ----------
    func programarCierre(ventanillaID: Int,
                         finEn: Date,
                         session: URLSession = .shared) async throws -> ProgramarCierreResponse {
        let url = API.base.appendingPathComponent("/ventanillas/\(ventanillaID)/programar_cierre")
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Formato EXACTO que espera el backend
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let body = ProgramarCierreRequest(fin_en: df.string(from: finEn))
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        
        if (200..<300).contains(http.statusCode) {
            do {
                return try JSONDecoder().decode(ProgramarCierreResponse.self, from: data)
            } catch {
                throw APIError.decoding(error.localizedDescription)
            }
        } else {
            // intenta leer {"error": "..."} del backend
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = obj["error"] as? String {
                throw APIError.http(http.statusCode, msg)
            }
            throw APIError.http(http.statusCode, nil)
        }
    }
    
    func getHorarioActual(ventanillaID: Int,
                          session: URLSession = .shared) async throws -> HorarioActualResponse {
        let url = API.base.appendingPathComponent("/ventanillas/\(ventanillaID)/horario_actual")
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = obj["error"] as? String {
                throw APIError.http(http.statusCode, msg)
            }
            throw APIError.http(http.statusCode, nil)
        }
        
        do {
            return try JSONDecoder().decode(HorarioActualResponse.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }
    
    func createTicket(pacienteID: Int,
                      prioridad: Int = 0,
                      session: URLSession = .shared) async throws -> Ticket {
        let url = API.base.appendingPathComponent("/postTurnos")
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let body = CreateTicketRequest(paciente_id: pacienteID, prioridad: prioridad)
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }

        if (200..<300).contains(http.statusCode) {
            let dto = try JSONDecoder().decode(TicketDTO.self, from: data)
            return Ticket(
                numeroDeTurno: dto.numeroDeTurno,
                nombrePaciente: dto.nombrePaciente,
                pantallaAnuncioSuperior: dto.turnoActivo ? "¡ES SU TURNO!" : "ESPERE SU VENTANILLA",
                pantallaVentanilla: dto.pantallaVentanilla ?? 0,
                turnoActivo: dto.turnoActivo,
                tiempoRestanteTurno: dto.tiempoRestanteTurno
            )
        } else {
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = obj["error"] as? String {
                throw APIError.http(http.statusCode, msg)
            }
            throw APIError.http(http.statusCode, nil)
        }
    }

    func fetchTicket(folio: String,
                     session: URLSession = .shared) async throws -> Ticket {
        let url = API.base.appendingPathComponent("/getTurnos/\(folio)")
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }

        if (200..<300).contains(http.statusCode) {
            let dto = try JSONDecoder().decode(TicketDTO.self, from: data)
            return Ticket(
                numeroDeTurno: dto.numeroDeTurno,
                nombrePaciente: dto.nombrePaciente,
                pantallaAnuncioSuperior: dto.turnoActivo ? "¡ES SU TURNO!" : "ESPERE SU VENTANILLA",
                pantallaVentanilla: dto.pantallaVentanilla ?? 0,
                turnoActivo: dto.turnoActivo,
                tiempoRestanteTurno: dto.tiempoRestanteTurno
            )
        } else {
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = obj["error"] as? String {
                throw APIError.http(http.statusCode, msg)
            }
            throw APIError.http(http.statusCode, nil)
        }
    }

    
}

