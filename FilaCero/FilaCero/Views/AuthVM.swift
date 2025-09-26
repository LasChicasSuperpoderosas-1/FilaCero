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

    // ---------- LOGIN ----------
    func login(email: String, password: String) async {
        isLoading = true; errorMessage = nil
        do {
            let res = try await APIClient.shared.login(correo: email, password: password)
            if res.ok, let uid = res.user_id {
                self.userId = uid
<<<<<<< Updated upstream
                self.rol = res.rol                 // 👈 guarda el rol
=======
                self.rol = res.rol
>>>>>>> Stashed changes
                self.isAuthenticated = true
            } else {
                self.errorMessage = res.msg ?? "Credenciales inválidas"
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // ---------- LOGOUT ----------
    func logout() async {
        guard let uid = userId else {
            // no hay sesión activa
            self.isAuthenticated = false
            return
        }
        do {
            try await APIClient.shared.logout(userId: uid)
        } catch {
            print("⚠️ Error en logout:", error.localizedDescription)
        }
        self.isAuthenticated = false
        self.userId = nil
        self.rol = nil
    }
}
