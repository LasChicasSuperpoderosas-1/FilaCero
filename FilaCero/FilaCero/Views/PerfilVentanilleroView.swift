//
//  PerfilVentanilleroView.swift
//  FilaCero
//
//  Created by Diego Saldaña on 26/09/25.
//

import SwiftUI

struct PerfilVentanilleroView: View {
    @EnvironmentObject var auth: AuthVM
    @State private var confirm = false

        // Hardcode de ejemplo; cámbialos cuando conectes API
        let nombre = "Juan Pérez"
        let correo = "ventanillero@ejemplo.com"
        let ventanillaCodigo = 2

        var body: some View {
            NavigationStack {
                List {
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable().frame(width: 64, height: 64)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(nombre).font(.title3).bold()
                                Text("Ventanillero").foregroundStyle(.secondary)
                            }
                        }.padding(.vertical, 4)
                    }

                    Section("Cuenta") {
                        ProfileRow(label: "Correo", value: correo)
                        ProfileRow(label: "ID Usuario", value: "\(auth.userId ?? 0)")
                        ProfileRow(label: "Rol", value: (auth.rol ?? "VENTANILLERO"))
                    }

                    Section("Mi ventanilla") {
                        ProfileRow(label: "Número de Ventanilla", value: "\(ventanillaCodigo)")
                    }

                    Section {
                        Button(role: .destructive) {
                            confirm = true
                        } label: {
                            Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
                .navigationTitle("Perfil")
                .confirmationDialog("¿Cerrar sesión?", isPresented: $confirm) {
                    Button("Cerrar sesión", role: .destructive) {
                        Task { await auth.logout() }
                    }
                    Button("Cancelar", role: .cancel) {}
                }
            }
        }
    }

private struct ProfileRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PerfilVentanilleroView()
}
