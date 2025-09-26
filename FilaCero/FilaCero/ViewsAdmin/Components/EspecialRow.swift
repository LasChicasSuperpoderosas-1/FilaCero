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
        HStack(alignment: .center, spacing: 12) {
            Text("# \(turnoespecial.id)")
                .font(.system(size: 22, weight: .bold))

            VStack(alignment: .leading, spacing: 4) {
                Text(turnoespecial.nombre)
                    .font(.system(size: 17, weight: .semibold))

                Text("Estado: \(turnoespecial.estado)")
                    .font(.system(size: 16))
            }

            Spacer()

            Text(turnoespecial.prioridad ? "Especial" : "Normal")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(turnoespecial.prioridad ? .orange : .gray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}


#Preview {
    EspecialRow(turnoespecial: TurnoEspecial(id: 12345, nombre: "Juan Pérez", estado: "Activo", prioridad: true))
}
