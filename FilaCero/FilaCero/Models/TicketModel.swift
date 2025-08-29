//
//  TicketModel.swift
//  FilaCero
//
//  Created by Emilio Puga on 28/08/25.
//

import Foundation

struct Ticket : Identifiable {
    let id = UUID()
    public var fecha: String
    public var numeroDeTurno: Int
    public var nombrePaciente: String
    public var horaRegistro: String
    public var horaActual: String
    public var pantallaAnuncioSuperior: String
    public var pantallaVentanilla: Int
    public var tiempoLimite: String
}
