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
    @State private var mostrarAlerta = false

    var body: some View {
        VStack(spacing: 0) {
            // Título
            Text("Turno Especial")
                .font(.system(size: 35, weight: .bold))
                .padding(.horizontal)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Error o lista de turnos
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
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
            }

            // Botón e
            Button(action: {
                mostrarAlerta = true
            }) {
                Text("Asignar Turno Especial")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 280, height: Brand.buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(turnoespecial == nil ? Color.gray.opacity(0.4) : Brand.primary)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .foregroundColor(.white)
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
            .disabled(turnoespecial == nil)
            .alert(isPresented: $mostrarAlerta) {
                Alert(
                    title: Text("Confirmar"),
                    message: Text("¿Seguro que quieres asignar este turno como especial?"),
                    primaryButton: .destructive(Text("No")),
                    secondaryButton: .default(Text("Sí"), action: {
                        if let seleccionado = turnoespecial {
                            updateViewModel.asignarTurnoEspecial(
                                nombrePaciente: seleccionado.nombre,
                                folioTurno: seleccionado.id
                            ) { success in
                                DispatchQueue.main.async {
                                    if success {
                                        viewModel.obtenerTurnosDesdeAPI()
                                        turnoespecial = nil
                                    }
                                }
                            }
                        }
                    })
                )
            }

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
