//
//  TurnoEspecial.swift
//  FilaCero
//
//  Created by Diego Saldaña on 24/09/25.
//

import Foundation

struct TurnoEspecial: Identifiable {
    var id: Int
    var nombre: String
    var estado: String
    var prioridad: Bool
    
    init(id: Int, nombre: String, estado: String, prioridad: Bool) {
        self.id = id
        self.nombre = nombre
        self.estado = estado
        self.prioridad = prioridad
    }
}

