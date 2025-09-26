//
//  Encuesta.swift
//  FilaCero
//
//  Created by Angel Orlando Anguiano Peña on 26/09/25.
//

import Foundation

struct Usuario {
    let id_usuario: Int
    let nombre: String
}

struct Sesion {
    let id_sesion: Int
    let fecha_inicio: Date
}

struct EncuestaRequest: Codable {
    let paciente_id: Int
    let sesion_id: Int?
    let calificacion: Int
    let encontro_medicamentos: Bool
    let comentario: String
}

struct EncuestaResponse: Codable {
    let status: String
    let msg: String
    let data: DataResponse?
    
    struct DataResponse: Codable {
        let id_encuesta: Int
        let creado_en: String
    }
}
