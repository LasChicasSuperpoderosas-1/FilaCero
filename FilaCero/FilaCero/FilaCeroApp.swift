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
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    switch (auth.rol ?? "").uppercased() {
                    case "ADMIN":
                        AdminHomeView().environmentObject(auth)
                    case "VENTANILLERO":
                        TabViewVentanilleroView().environmentObject(auth)
                    case "PACIENTE":
                        InicioView().environmentObject(auth)
                    default:
                        InicioView().environmentObject(auth) 
                    }
                } else {
                    LoginView().environmentObject(auth)
                }
            }
        }
    }
}


