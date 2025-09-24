//
//  VentanillasEnvelope.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import Foundation

struct VentanillasEnvelope: Decodable {
    let ok: Bool
    let ventanillas: [Ventanilla]
}
