//
//  TabViewVentanilleroView.swift
//  FilaCero
//
//  Created by Marco de la Puente on 20/09/25.
//

import SwiftUI

struct TabViewVentanilleroView: View {
    var body: some View {
        TabView{
            SiguienteTurnoView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Ventanilla")
                }
            LoginView()
                .tabItem {
                    Image(systemName: "questionmark.circle")
                    Text("Recomendación")
                }
        }.tabViewStyle(DefaultTabViewStyle())
            .tint(Brand.primary)
        
    }
}

#Preview {
    TabViewVentanilleroView()
}
