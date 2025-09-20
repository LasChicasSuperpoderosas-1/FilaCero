//
//  TestEspecialDatos.swift
//  FilaCero
//
//  Created by Diego Saldaña on 19/09/25.
//

import Foundation

var listaEspecial = obtenerEspecial()

func obtenerEspecial() -> Array<TestEspecial> {
    var listaEspecial: Array<TestEspecial> = []
    
    listaEspecial = [
        TestEspecial(id: 1, nombre: "Diego Saldaña", edad: 21, socio: 01571609),
        TestEspecial(id: 2, nombre: "Pablo Zapata", edad: 20, socio: 00839242),
        TestEspecial(id: 3, nombre: "Angel Peña", edad: 19, socio: 00838418),
        TestEspecial(id: 4, nombre: "Emilio Puga", edad: 21, socio: 01285821),
        TestEspecial(id: 5, nombre: "Marco Antonio", edad: 20, socio: 01285789),
        TestEspecial(id: 6, nombre: "Cristian Jordy", edad: 30, socio: 00998753)
        
    ]
    
    return listaEspecial
}
