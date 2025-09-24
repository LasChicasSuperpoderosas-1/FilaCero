//
//  VentanillaRowCard.swift
//  FilaCero
//
//  Created by Emilio Puga on 23/09/25.
//

import SwiftUI

struct VentanillaRowCard: View {
    let ventanilla: Ventanilla

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(ventanilla.titulo)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)

            Spacer(minLength: 8)

            StatusVent(estado: ventanilla.estado)

            Image(systemName: "chevron.right")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black.opacity(0.5))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
            VentanillaRowCard(
                ventanilla: .init(id: 1, codigo: 1, activa: false, estado: .APAGADA)
            )
            VentanillaRowCard(
                ventanilla: .init(id: 2, codigo: 2, activa: true, estado: .LIBRE)
            )
            VentanillaRowCard(
                ventanilla: .init(id: 3, codigo: 3, activa: true, estado: .OCUPADA)
            )
            VentanillaRowCard(
                ventanilla: .init(id: 4, codigo: 4, activa: true, estado: .RECESO)
            )
        }
        .padding()
}
