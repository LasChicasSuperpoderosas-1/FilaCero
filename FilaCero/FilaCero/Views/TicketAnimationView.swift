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
        numeroDeTurno : Int.random(in: 1...999),
        nombrePaciente: "Federico Jimenez",
        pantallaAnuncioSuperior: "Es Su turno!",
        pantallaVentanilla: 4,
        turnoActivo: false,
        tiempoRestanteTurno: 5
        )

    @Binding public var showTicket: Bool
    
    var body: some View {
        NavigationStack{
            VStack{
                
                TicketView(data: ticket, showTicket: $showTicket)
                    .frame(width: 400)
                    .offset(y: posicionInicial)
                    .onAppear {
                        iniciarAnimacion()
                    }
                Spacer()
                HStack{
                    NavigationLink("Encuesta"){
                        EncuestaView()
                            .navigationBarBackButtonHidden(true)
                    }
                    Button("prueba turno"){
                        ticket.turnoActivo.toggle()
                    }
                }
                .padding()
                .clipShape(.buttonBorder)
            }
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
    TicketAnimationView(showTicket: .constant(false))
}
