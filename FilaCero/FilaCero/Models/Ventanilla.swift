//
//  Ventanilla.swift
//  FilaCero
//
//  Created by Alumno on 22/09/25.
//

import Foundation
import SwiftUI

enum VentanillaEstado: String, Codable, CaseIterable, Identifiable{
    case APAGADA, RECESO, LIBRE, OCUPADA
    var id: String{ rawValue }
    var display: String{
        switch self{
        case .APAGADA: return "Apagada"
        case .RECESO: return "Receso"
        case .LIBRE: return "Libre"
        case .OCUPADA: return "Ocupada"
        }
    }
}

struct Ventanilla: Codable, Identifiable{
    
    let id: Int
    let codigo: Int
    let activa: Bool
    let estado: VentanillaEstado
    
    var titulo: String { "Ventanilla \(codigo)" }
    
    enum CodingKeys: String, CodingKey {
        case id = "id_ventanilla"
        case codigo = "codigo_ventanilla"
        case activa
        case estado
    }
    
}
