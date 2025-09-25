//
//  LoginView.swift
//  FilaCero
//
//  Created by Alumno on 26/08/25.
//

//VISTA PARA PACIENTE, VENTANILLERO, Y ADMINISTRADOR

import SwiftUI

struct LoginView: View {

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showMain = false
    @State private var showErrorAlert = false
    @StateObject private var auth = AuthVM()

    var body: some View {
        VStack {
            Image("LogoNova")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
                .frame(width: 212)
            Text("Gestión de turnos")
                .foregroundStyle(Color(red:102/255, green:102/255, blue:102/255))
                .bold()
                .font(.system(size:20))
                .padding(.bottom, 40)
            
            Group {
                Text("Correo electrónico")
                    .foregroundStyle(Color(red:102/255, green:102/255, blue:102/255))
                    .bold()
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                TextField("Ingresa tu correo electrónico", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 22)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 1/255, green: 104/255, blue: 138/255)))
                    .tint(Color(red: 153/255, green: 153/255, blue: 153/255))
                    .frame(width: 360)
            }
            .padding(.bottom, 10)

            // Password
            Group {
                Text("Contraseña")
                    .foregroundStyle(Color(red:102/255, green:102/255, blue:102/255))
                    .bold()
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                SecureField("Ingresa tu contraseña", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 22)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 1/255, green: 104/255, blue: 138/255), lineWidth: 1))
                    .tint(Color(red: 153/255, green: 153/255, blue: 153/255))
                    .frame(width: 360)
            }

            // Botón
            Button {
                Task {
                    await auth.login(email: email, password: password)
                    if auth.isAuthenticated {
                        password.removeAll()
                        showMain = true
                    } else if auth.errorMessage != nil {
                        showErrorAlert = true
                    }
                }
            } label: {
                ZStack {
                    Text("Iniciar Sesión")
                        .font(.system(size: 35, weight: .bold))
                        .frame(maxWidth: 300)
                        .frame(height: 56)
                        .opacity(auth.isLoading ? 0 : 1)

                    if auth.isLoading {
                        ProgressView().progressViewStyle(.circular)
                    }
                }
            }
            .background((email.isEmpty || password.isEmpty) ?
                        Color(red: 211/255, green: 211/255, blue: 211/255) :
                        Color(red: 1/255, green: 104/255, blue: 138/255))
            .cornerRadius(17)
            .tint((email.isEmpty || password.isEmpty) ? .black :
                  Color(red: 242/255, green: 242/255, blue: 242/255))
            .padding(.top, 20)
            .disabled(email.isEmpty || password.isEmpty || auth.isLoading)
        }
        .fullScreenCover(isPresented: $showMain) {
            NavigationStack {
                switch auth.rol {
                case "ADMIN":
                    AdminHomeView()
                case "VENTANILLERO":
                    VentanillaPrueba()
                case "PACIENTE":
                    EncuestaView()
                default:
                    InicioView(isSignedIn: $showMain)
                }
            }
        }
        // Muestra pop-up cuando haya error
        .alert("Credenciales inválidas", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {
                // opcional: limpiar mensaje después
                auth.errorMessage = nil
            }
        } message: {
            Text(auth.errorMessage ?? "Revisa tu correo y contraseña.")
        }
        // Dispara el alert automáticamente al cambiar el mensaje
        .onChange(of: auth.errorMessage) { msg in
            if msg != nil { showErrorAlert = true }
        }
    }
}

#Preview { LoginView() }

