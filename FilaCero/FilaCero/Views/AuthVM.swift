//
//  AuthVM.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import Foundation

// AuthVM.swift
@MainActor
final class AuthVM: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userId: Int?
    @Published var rol: String?          // 👈 añade esto
    @Published var isLoading = false
    @Published var errorMessage: String?

    func login(email: String, password: String) async {
        isLoading = true; errorMessage = nil
        do {
            let res = try await APIClient.shared.login(correo: email, password: password)
            if res.ok, let uid = res.user_id {
                self.userId = uid
                self.rol = res.rol                 // 👈 guarda el rol
                self.isAuthenticated = true
            } else {
                self.errorMessage = res.msg ?? "Credenciales inválidas"
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

