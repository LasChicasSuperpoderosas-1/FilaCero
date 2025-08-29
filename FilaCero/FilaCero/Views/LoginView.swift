//
//  LoginView.swift
//  FilaCero
//
//  Created by Alumno on 26/08/25.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var colorBoton : Color = Color(red: 211/255, green: 211/255, blue: 211/255)
    @State public var showMain = false
    
    var body: some View {
        VStack{
            Image("LogoNova")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
                .frame(width: 212)
            Text("Gestión de turnos")
                .foregroundStyle(Color(red:102/255, green: 102/255, blue: 102/255)) //Hex: #666666
                .bold()
                .font(.system(size:20))
                .padding(.bottom, 40)
            
            
            Text("Correo electrónico")
                .foregroundStyle(Color(red:102/255, green: 102/255, blue: 102/255)) //Hex: #666666
                .bold()
                .font(.system(size: 20))
                .padding(.leading, -180)
            TextField("Ejemplo@ternium", text: $email)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 1/255, green: 104/255, blue: 138/255))
                    )// HEX: #01688A
                .tint(Color(red: 153/255, green: 153/255,blue: 153/255))
                .padding(.bottom, 10)
                .frame(width: 360)
                
            
            
            Text("Contraseña")
                .foregroundStyle(Color(red:102/255, green: 102/255, blue: 102/255)) //Hex: #666666
                .bold()
                .font(.system(size: 20))
                .padding(.leading, -180)
            SecureField("Ingresa tu contraseña", text: $password)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 1/255, green: 104/255, blue: 138/255), lineWidth: 1)
                    )// HEX: #01688A
                .tint(Color(red: 153/255, green: 153/255,blue: 153/255))
                .padding(.bottom, 10)
                .frame(width: 360)
            
            
            Button("Olvidé mi contraseña") {
                email = "JAJAJA no sabe su contraseña"
            }.padding(.leading, -180)
                .tint(Color(red: 1/255, green: 104/255, blue: 138/255))
            
            Button("Iniciar Sesión") {
               if email.contains("@") && !email.isEmpty{
                    // Se pasa al inicio
                   showMain = true
                }
            }.frame(width: 170, height: 45)
                .background(
                    (email.isEmpty || password.isEmpty) ? Color(red: 211/255, green: 211/255, blue: 211/255) : Color(red: 1/255, green: 104/255, blue: 138/255)
                ) //Hex: #D3D3D3
                .cornerRadius(17)
                .padding(.leading, 0)
                .tint(
                    (email.isEmpty || password.isEmpty) ? Color(.black) : Color(red: 242/255, green: 242/255, blue: 242/255).opacity(1)
                )
                .padding(.top, 50)
                .disabled(email.isEmpty || password.isEmpty)
                
        }        .fullScreenCover(isPresented: $showMain) {
            // Puedes tener NavigationStack aquí dentro si tu “main” navega
            NavigationStack {
                InicioView(isSignedIn:$showMain)
            }
            
        }
        //.background(Color(red: 242/255, green: 242/255, blue: 242/255).opacity(0.5))
    
    }//HEX: #F2F2F2
}

#Preview {
    LoginView()
}
