//
//  TurnoEspecialView.swift
//  FilaCero
//
//  Created by Diego Saldaña on 19/09/25.
//

import Foundation
import SwiftUI

struct TurnoEspecialView: View {
    @State private var turnoespecial: TurnoEspecial?
    @StateObject private var viewModel = TurnoEspecialViewModel()
    @StateObject private var updateViewModel = PrioridadViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Título
            Text("Turno Especial")
                .font(.system(size: 35, weight: .bold))
                .padding(.horizontal)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Lista de turnos especiales
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.listaEspecial) { item in
                        EspecialRow(turnoespecial: item)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Color.white
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                Group {
                                    if turnoespecial?.id == item.id {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Brand.primary.opacity(0.3))
                                            .transition(.opacity)
                                    }
                                }
                            )
                            .onTapGesture {
                                withAnimation {
                                    turnoespecial = (turnoespecial?.id == item.id) ? nil : item
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }

            // Botón
            Button(action: {
                if let seleccionado = turnoespecial {
                    updateViewModel.asignarTurnoEspecial(nombrePaciente: seleccionado.nombre) { success in
                        DispatchQueue.main.async {
                            if success {
                                viewModel.obtenerTurnosDesdeAPI()
                                turnoespecial = nil
                            }
                        }
                    }
                }
            }) {
                Text("Asignar Turno Especial")
                    .font(.system(size: 25, weight: .bold))
                    .frame(width: 280, height: Brand.buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Brand.primary)
                    )
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Línea divisoria inferior
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black.opacity(0.2))
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            viewModel.obtenerTurnosDesdeAPI()
        }
    }
}

#Preview {
    TurnoEspecialView()
}
