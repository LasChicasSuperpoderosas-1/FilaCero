//
//  PerfilView.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import SwiftUI

struct PerfilView: View {
    @EnvironmentObject var auth: AuthVM
    @State private var confirm = false

        var body: some View {
            NavigationStack {
                List {
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable().frame(width: 64, height: 64)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pablo Emilio González").font(.title3).bold()
                                Text("Administrador").foregroundStyle(.secondary)
                            }
                        }.padding(.vertical, 4)
                    }

                    Section("Cuenta") {
                        ProfileRow(label: "Correo", value: "admin@ejemplo.com")
                        ProfileRow(label: "ID Usuario", value: "\(auth.userId ?? 0)")
                        ProfileRow(label: "Rol", value: (auth.rol ?? "ADMIN"))
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
                .navigationBarTitleDisplayMode(.large)
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
    PerfilView()
}
