//
//  TicketModel.swift
//  FilaCero
//
//  Created by Emilio Puga on 28/08/25.
//

import Foundation

struct Ticket : Identifiable {
    let id = UUID()
    public var numeroDeTurno: Int
    public var nombrePaciente: String
    public var pantallaAnuncioSuperior: String
    public var pantallaVentanilla: Int
    public var turnoActivo: Bool
    public var tiempoRestanteTurno: Int
}

// MARK: - Requests/Responses del backend
struct CreateTicketRequest: Codable {
    let paciente_id: Int
    let prioridad: Int
}

struct TicketDTO: Codable {
    let id_turno: Int
    let numeroDeTurno: Int
    let folio_turno: String
    let nombrePaciente: String
    let turnoActivo: Bool
    let pantallaVentanilla: Int?
    let tiempoRestanteTurno: Int
}

