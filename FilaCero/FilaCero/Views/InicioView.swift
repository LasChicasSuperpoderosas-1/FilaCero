//
//  InicioView.swift
//  FilaCero
//
//  Created by Alumno on 26/08/25.
//

import SwiftUI

enum Brand {
    static let primary = Color(red: 1/255, green: 104/255, blue: 138/255)        // #01688A
    static let textPrimary  = Color(red: 51/255,  green: 51/255,  blue: 51/255)  // #333333
    static let textSecondary = Color(red: 102/255, green: 102/255, blue: 102/255)// #666666
    static let appBackground = Color(red: 242/255, green: 242/255, blue: 242/255)// #F2F2F2
    static let cardRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 56
}

struct InicioView: View {
    var onGenerateTurn: () -> Void = {}
    var onSignOut: () -> Void = {}
    var patientName: String = "Pablo Emilio González"

    @State private var appeared = false
    @State public var showTicket = false // Variable para cambiar al ticket
    @Binding public var isSignedIn: Bool // Variable de Binding con showMain
    

    var body: some View {
        VStack() {

            VStack() {
                Image("LogoNova")
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 212)

                Text("Gestión de turnos")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Brand.textSecondary)
                    .padding(.bottom, 12)
            }
            .padding(.top, 8)


            VStack(spacing: 24) {

                VStack() {
                    Text("Bienvenido,")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Brand.textPrimary)
                    Text(patientName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Brand.primary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.6), value: appeared)


                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Cómo funciona?")
                        .font(.headline.bold())
                        .foregroundStyle(Brand.primary.opacity(0.9))
                        .padding(.bottom, 4)


                    HStack(alignment: .top, spacing: 12) {
                        Text("1")
                            .font(.footnote.bold())
                            .foregroundStyle(Brand.primary.opacity(0.95))
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Brand.primary.opacity(0.18)))
                            .overlay(Circle().stroke(Brand.primary.opacity(0.35), lineWidth: 1))
                            
                        Text("Presione el botón de \"Generar Turno\"")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Brand.textPrimary)
                    }

  
                    HStack(alignment: .top, spacing: 12) {
                        Text("2")
                            .font(.footnote.bold())
                            .foregroundStyle(Brand.primary.opacity(0.95))
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Brand.primary.opacity(0.18)))
                            .overlay(Circle().stroke(Brand.primary.opacity(0.35), lineWidth: 1))
                            
                        Text("Espere a ser llamado")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Brand.textPrimary)
                    }

   
                    HStack(alignment: .top, spacing: 12) {
                        Text("3")
                            .font(.footnote.bold())
                            .foregroundStyle(Brand.primary.opacity(0.95))
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Brand.primary.opacity(0.18)))
                            .overlay(Circle().stroke(Brand.primary.opacity(0.35), lineWidth: 1))
                            
                        Text("Diríjase a la ventanilla asignada")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Brand.textPrimary)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: Brand.cardRadius, style: .continuous)
                        .fill(Brand.primary.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Brand.cardRadius, style: .continuous)
                        .stroke(Brand.primary.opacity(0.22), lineWidth: 1.5)
                )


                VStack(spacing: 2) {
                    Text("¿Necesita ayuda?")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(Brand.textPrimary)
                    Text("Acérquese a recepción")
                        .font(.system(size: 19))
                        .fontWeight(.regular)
                        .foregroundStyle(Brand.textSecondary)
                }
                .padding(.trailing, 1)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
            }
            .padding(.top, 8)
            .padding(.bottom,3)


            Spacer()


            Button(action: {
                showTicket = true // Variable para el fullscreencover
            }) {
                Text("Generar Turno")
                    .font(.system(size:30, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: Brand.buttonHeight)
            }
            .buttonStyle(.borderedProminent)
            .tint(Brand.primary)
            
            .fullScreenCover(isPresented: $showTicket){
                TicketAnimationView(showTicket: $showTicket)
            }
            
            Spacer()

            Button(action: {
                isSignedIn = false // Variable para regresar al login con el showMain
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .imageScale(.medium)
                        .font(.system(size:25))
                    Text("Cerrar sesión")
                        .font(.system(size:25, weight: .bold))
                }
                .frame(height: 50)
            }
            .buttonStyle(.bordered)
            .tint(Brand.primary)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: 520)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)


        .background {
            Brand.appBackground.ignoresSafeArea()
        }
        .onAppear { appeared = true }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("Inicio") {
    InicioView(
        onGenerateTurn: { print("Preview: turno generado") },
        onSignOut: { print("Preview: cerrar sesión") },
        isSignedIn: .constant(false), // Aqui pasa el binding
    )
}
