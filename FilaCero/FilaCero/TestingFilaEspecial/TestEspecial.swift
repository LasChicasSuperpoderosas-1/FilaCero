//
//  TestEspecial.swift
//  FilaCero
//
//  Created by Diego Saldaña on 19/09/25.
//

import Foundation

struct TestEspecial: Identifiable{
    var id: Int
    var nombre: String
    var edad: Int
    var socio: Int
    
    init(id: Int, nombre: String, edad: Int, socio: Int) {
        self.id = id
        self.nombre = nombre
        self.edad = edad
        self.socio = socio
    }
}
