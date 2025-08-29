//
//  TicketAnimationView.swift
//  FilaCero
//
//  Created by Emilio Puga on 27/08/25.
//

import SwiftUI

struct TicketAnimationView: View {
    @State private var posicionInicial: CGFloat = -820
    @State private var controlAnimacion = false
    
    @State private var ticket = Ticket(
        fecha :"27/08/2025",
        numeroDeTurno : Int.random(in: 1...999),
        nombrePaciente: "Federico Jimenez",
        horaRegistro: "19:30:30",
        horaActual:  "19:46:23",
        pantallaAnuncioSuperior: "Es Su turno!",
        pantallaVentanilla: 4,
        turnoActivo: false,
        tiempoRestanteTurno: 180
        )

    var body: some View {
        VStack{
            
            TicketView(data: ticket)
                .frame(width: 400)
                .offset(y: posicionInicial)
                .onAppear {
                    iniciarAnimacion()
                }
            Spacer()
            HStack{
                Button("Prueba"){
                    reinnciarAnimacion()
                }
                Button("prueba turno"){
                    ticket.turnoActivo.toggle()
                }
            }
            .padding()
            .clipShape(.buttonBorder)
        }
    }
    
    private func iniciarAnimacion() {
        withAnimation(.none) { posicionInicial = -820 }

            withAnimation(.easeIn(duration: 1.6).delay(0.2)) {
                posicionInicial = -180
            }

            withAnimation(.linear(duration: 0.30).delay(2.25)) {
                posicionInicial = -310
            }

            withAnimation(.linear(duration: 0.45).delay(2.75)) {
                posicionInicial = -180
            }

            withAnimation(.interpolatingSpring(stiffness: 220, damping: 15).delay(2.30)) {
                posicionInicial = 0
            }
        }
        
        private func reinnciarAnimacion() {
            posicionInicial = -820
            iniciarAnimacion()
        }
}

#Preview {
    TicketAnimationView()
}
