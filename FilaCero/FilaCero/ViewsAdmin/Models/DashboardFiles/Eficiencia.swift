//
//  Eficiencia.swift
//  FilaCero
//
//  Created by Angel Orlando Anguiano Peña on 25/09/25.
//

import Foundation


struct EficienciaResponse: Codable {
    let ok: Bool
    let data: [Eficiencia]
}

struct Eficiencia: Codable, Identifiable {
    let ventanilla_id: Int
    let turnos_atendidos: Int
    
    var id: Int { ventanilla_id }
}

