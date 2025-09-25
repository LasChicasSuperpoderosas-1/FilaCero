//
//  ProgramarCierreRequest.swift
//  FilaCero
//
//  Created by Emilio Puga on 24/09/25.
//

import Foundation

// Programar cierre automático
struct ProgramarCierreRequest: Codable {
    let fin_en: String   // "YYYY-MM-DD HH:mm:ss"
}

struct ProgramarCierreResponse: Codable {
    let ok: Bool
    let ventanilla_id: Int
    let fin_en: String
}

struct HorarioActualResponse: Codable {
    let ok: Bool
    let ventanilla: HorarioVentanilla
    let asignacion: HorarioAsignacion?
    let auto_cierre: AutoCierre

    struct HorarioVentanilla: Codable {
        let id_ventanilla: Int
        let codigo_ventanilla: Int?
        let activa: Int?
        let estado: String?
    }
    struct HorarioAsignacion: Codable {
        let id_asignacion: Int
        let ventanillero_id: Int
        let inicio_en: String?
        let fin_en: String?
    }
    struct AutoCierre: Codable {
        let enabled: Bool
        let fin_en: String?
    }
}
