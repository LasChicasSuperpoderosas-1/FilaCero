//
//  VentInfoRow.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import SwiftUI

struct VentInfoRow: View {
    let icon: String
        let title: String
        let subtitle: String
        var tint: Color = .blue

        var body: some View {
            HStack(spacing: 16) {
                IconBadge(systemName: icon, tint: tint)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)

                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.65))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.5))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
            )
        }
    }

    #Preview {
        VStack(spacing: 20) {
            VentInfoRow(
                icon: "clock",
                title: "Horarios",
                subtitle: "Configurar horarios de atención al cliente"
            )
            VentInfoRow(
                icon: "power",
                title: "Habilitar/Deshabilitar",
                subtitle: "Cambiar estado de la ventanilla"
            )
            VentInfoRow(
                icon: "clock.arrow.circlepath",
                title: "Historial",
                subtitle: "Ver historial de atenciones"
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
