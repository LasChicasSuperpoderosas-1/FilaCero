//
//  FilaCeroApp.swift
//  FilaCero
//
//  Created by Diego Saldaña on 21/08/25.
//
import SwiftUI
@main
struct FilaCeroApp: App {
    @StateObject private var auth = AuthVM()

    var body: some Scene {
<<<<<<< Updated upstream
        WindowGroup { LoginView() }

=======
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    InicioView()            // tu pantalla principal
                } else {
                    LoginView()
                }
            }
            .environmentObject(auth)       // ← inyecta el VM a todo el árbol
        }
>>>>>>> Stashed changes
    }
}


