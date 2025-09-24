//
//  FilaCeroApp.swift
//  FilaCero
//
//  Created by Diego Saldaña on 21/08/25.
//
import SwiftUI
@main
struct FilaCeroApp: App {
    init() {
        VentanillaHabDesAPI.configurePin(certName: "tc2007b", ext: "cer")
    }

    var body: some Scene {
        WindowGroup { AdminPrueba() }
    }
}

