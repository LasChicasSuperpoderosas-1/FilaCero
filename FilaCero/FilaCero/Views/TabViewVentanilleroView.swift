//
//  TabViewVentanilleroView.swift
//  FilaCero
//
//  Created by Marco de la Puente on 20/09/25.
//

import SwiftUI

struct TabViewVentanilleroView: View {
    @EnvironmentObject var auth: AuthVM
    var body: some View {
        TabView{
            SiguienteTurnoView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Ventanilla")
                }
            PerfilVentanilleroView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Perfil")
                }
                .environmentObject(auth)
        }.tabViewStyle(DefaultTabViewStyle())
            .tint(Brand.primary)
        
    }
}

#Preview {
    TabViewVentanilleroView()
}
