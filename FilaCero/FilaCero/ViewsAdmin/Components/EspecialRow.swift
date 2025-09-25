//
//  EspecialRow.swift
//  FilaCero
//
//  Created by Diego Saldaña on 19/09/25.
//
import Foundation
import SwiftUI

struct EspecialRow: View {
    let turnoespecial: TurnoEspecial
    
    var body: some View {
        HStack(alignment: .center) {
            Text("# \(turnoespecial.id)")
                .font(.system(size: 25, weight: .bold))
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(turnoespecial.nombre)
                    .font(.system(size: 17, weight: .bold))
                
                Divider()
                
                Text("Estado: \(turnoespecial.estado)")
                    .font(.system(size: 17))
            }
            .padding(.trailing, 20)
            
            Text(turnoespecial.prioridad ? "Especial" : "Normal")
                .font(.system(size: 17))
                .foregroundColor(turnoespecial.prioridad ? .orange : .gray)
                .padding(.bottom, 30)
            
            Spacer()
        }
        .foregroundStyle(.black)
    }
}

#Preview {
    EspecialRow(turnoespecial: TurnoEspecial(id: 12345, nombre: "Juan Pérez", estado: "Activo", prioridad: true))
}
