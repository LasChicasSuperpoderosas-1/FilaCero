//
//  HistorialAPI.swift
//  FilaCero
//
//  Created by Jordy Granados on 24/09/25.
//

import Foundation

struct HistorialResponse: Decodable {
    let ok: Bool
    let page: Int
    let size: Int
    let total: Int
    let items: [HistorialItemDTO]
}

struct HistorialItemDTO: Decodable {
    let id: Int
    let ventanillaCodigo: Int
    let folioTurno: Int
    let pacienteNombre: String
    let ventanilleroNombre: String
    let sesionEstado: String
    let turnoEstado: String
    let prioridad: Bool
    let inicio: Date
    let llamado: Date?
    let fin: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case ventanillaCodigo = "ventanilla_codigo"
        case folioTurno       = "folio_turno"
        case pacienteNombre   = "paciente_nombre"
        case ventanilleroNombre = "ventanillero_nombre"
        case sesionEstado     = "sesion_estado"
        case turnoEstado      = "turno_estado"
        case prioridad
        case inicio, llamado, fin
    }
}

struct HistorialAPI {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207")!,
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetch(
        page: Int,
        size: Int,
        ventanilla: Int?,
        prioridad: Prioridad?,
        desde: Date?,
        hasta: Date?,
        query: String
    ) async throws -> [Atencion] {
        var comps = URLComponents(url: baseURL.appendingPathComponent("/historial/atenciones"),
                                  resolvingAgainstBaseURL: false)
        var q: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        if let v = ventanilla { q.append(URLQueryItem(name: "ventanilla", value: String(v))) }
        if let p = prioridad { q.append(URLQueryItem(name: "prioridad", value: p.rawValue)) }
        if let d = desde { q.append(URLQueryItem(name: "desde", value: Self.yyyyMMdd(d))) }
        if let h = hasta { q.append(URLQueryItem(name: "hasta", value: Self.yyyyMMdd(h))) }
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            q.append(URLQueryItem(name: "q", value: query))
        }
        comps?.queryItems = q
        guard let url = comps?.url else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "HTTP error"
            throw NSError(domain: "HistorialAPI", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }

        let dec = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        dec.dateDecodingStrategy = .formatted(formatter)

        let payload = try dec.decode(HistorialResponse.self, from: data)

        return payload.items.map { dto in
            Atencion(
                id: dto.id,
                ventanillaCodigo: dto.ventanillaCodigo,
                folioTurno: "T-\(dto.folioTurno)",
                pacienteNombre: dto.pacienteNombre,
                ventanilleroNombre: dto.ventanilleroNombre,
                sesionEstado: SesionEstado(rawValue: dto.sesionEstado) ?? .asignado,
                turnoEstado: TurnoEstado(rawValue: dto.turnoEstado) ?? .pendiente,
                prioridad: dto.prioridad ? .especial : .normal, 
                inicio: dto.inicio,
                llamado: dto.llamado,
                fin: dto.fin
            )
        }
    }

    private static func yyyyMMdd(_ d: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let c = cal.dateComponents([.year,.month,.day], from: d)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }
}

extension HistorialAPI {
    static func fetch(page: Int, size: Int) async throws -> [Atencion] {
        try await HistorialAPI().fetch(
            page: page,
            size: size,
            ventanilla: nil,
            prioridad: nil,
            desde: nil,
            hasta: nil,
            query: ""
        )
    }
}
