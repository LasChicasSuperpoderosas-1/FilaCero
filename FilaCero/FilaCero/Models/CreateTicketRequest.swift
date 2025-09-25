//
//  CreateTicketRequest.swift
//  FilaCero
//
//  Created by Emilio Puga on 25/09/25.
//


// MARK: - POST /postTurnos
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
    let pantallaVentanilla: Int?   // backend puede mandarlo nulo
    let tiempoRestanteTurno: Int
}

// MARK: - Dominio para tu UI (lo que consume TicketView)
struct TicketModelApi: Identifiable {
    let id: Int
    let numeroDeTurno: Int
    let nombrePaciente: String
    let pantallaVentanilla: Int
    let turnoActivo: Bool
    let tiempoRestanteTurno: Int
    // Extra opcional que tu vista usa en el preview; lo rellenamos nosotros:
    let pantallaAnuncioSuperior: String

    init(from dto: TicketDTO) {
        self.id = dto.id_turno
        self.numeroDeTurno = dto.numeroDeTurno
        self.nombrePaciente = dto.nombrePaciente
        self.pantallaVentanilla = dto.pantallaVentanilla ?? 0
        self.turnoActivo = dto.turnoActivo
        self.tiempoRestanteTurno = dto.tiempoRestanteTurno
        self.pantallaAnuncioSuperior = dto.turnoActivo ? "¡ES SU TURNO!" : "ESPERE SU VENTANILLA"
    }
}
