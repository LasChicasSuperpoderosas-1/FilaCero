//
//  TurnoEspecialView.swift
//  FilaCero
//
//  Created by Diego Saldaña on 19/09/25.
//

//VISTA PARA ADMINISTRADOR
import Foundation
import SwiftUI

struct TurnoEspecialView: View {
    @State private var turnoespecial: TurnoEspecial?
    @StateObject private var viewModel = TurnoEspecialViewModel()
    @StateObject private var updateViewModel = PrioridadViewModel()

    var body: some View {
        VStack {
            Text("Turno Especial")
                .font(.system(size: 35, weight: .bold))
                .padding()
            
            List(viewModel.listaEspecial) { item in
                EspecialRow(turnoespecial: item)
                    .contentShape(Rectangle())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(turnoespecial?.id == item.id ? Brand.primary.opacity(0.3) : Color.clear)
                            .frame(width: 350, height: 60)
                    )
                    .onTapGesture {
                        turnoespecial = (turnoespecial?.id == item.id) ? nil : item
                    }
            }
            
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
                    .font(.system(size:25, weight: .bold))
                    .frame(width: 280)
                    .frame(height: Brand.buttonHeight)
            }
            .buttonStyle(.borderedProminent)
            .tint(Brand.primary)
            
            Spacer()
        }
        .onAppear {
            viewModel.obtenerTurnosDesdeAPI()
        }
    }
}

#Preview {
    TurnoEspecialView()
}
