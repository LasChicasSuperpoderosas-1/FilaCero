//
//  Ventanillero.swift
//  FilaCero
//
//  Created by Angel Orlando Anguiano Peña on 25/09/25.
//

import Foundation

struct VentanilleroResponse: Codable {
    let ok: Bool
    let data: [Ventanillero]
}

struct Ventanillero: Codable, Identifiable {
    let id_usuario: Int
    let nombre_completo: String
    let total_atendidos: Int
    
    var id: Int { id_usuario }
}
