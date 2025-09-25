//
//  Turnos.swift
//  FilaCero
//
//  Created by Diego Saldaña on 24/09/25.
//

import Foundation

struct Turnos: Codable{
    var estado: String
    var folio_turno: Int
    var nombre_completo: String
    var prioridad: Bool
}

struct TurnosResponse: Codable {
    var ok: Bool
    var turnos: [Turnos]
}

