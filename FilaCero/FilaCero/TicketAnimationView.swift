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
    
    var body: some View {
        VStack{
            
            Image("EjemploTicket")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400)
                .offset(y: posicionInicial)
                .onAppear {
                    iniciarAnimacion()
                }
            Spacer()
            
            Button("Prueba"){
                reinnciarAnimacion()
            }
            .padding()
            .background(.blue)
            .clipShape(.buttonBorder)
        }
    }
    
    private func iniciarAnimacion() {
            withAnimation(.easeInOut(duration: 10)) {
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
