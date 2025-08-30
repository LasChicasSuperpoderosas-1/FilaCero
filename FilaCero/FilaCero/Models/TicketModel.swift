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
