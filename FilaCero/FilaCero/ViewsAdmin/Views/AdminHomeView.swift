//
//  AdminHomeView.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import SwiftUI

enum AdminTab: Hashable {
    case ventanillas
    case estadisticas
    case perfil
    case turno_especial
}

struct AdminHomeView: View {
    @EnvironmentObject var auth: AuthVM
    @State private var selection: AdminTab = .ventanillas

    var body: some View {
        TabView(selection: $selection) {

            NavigationStack {
                VentanillasHomeView()
                    .navigationTitle("Ventanillas")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Ventanillas", systemImage: "rectangle.3.group")
            }
            .tag(AdminTab.ventanillas)

            NavigationStack {
                DashboardView()
                    .navigationTitle("Estadísticas")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Estadísticas", systemImage: "chart.bar.xaxis")
            }
            .tag(AdminTab.estadisticas)
            
            NavigationStack {
                TurnoEspecialView()
                    .navigationTitle("Turno Especial")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Turno Especial", systemImage: "list.bullet.rectangle.fill")
            }
            .tag(AdminTab.turno_especial)

            NavigationStack {
                PerfilView()
                    .navigationTitle("Perfil")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Perfil", systemImage: "person.crop.circle")
            }
            .tag(AdminTab.perfil)
            .environmentObject(auth)
            
        }
    }
}

#Preview {
    AdminHomeView()
}

