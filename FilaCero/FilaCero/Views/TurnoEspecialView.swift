//
//  TurnoEspecialView.swift
//  FilaCero
//
//  Created by Diego Saldaña on 19/09/25.
//

import SwiftUI

struct TurnoEspecialView: View {
    
    @State private var testespecial: TestEspecial?
    
    var body: some View {
        
        VStack {
            Text("Turno Especial")
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding()
            

            
            List(listaEspecial) { item in
                EspecialRow(testespecial: item)
                    .contentShape(Rectangle())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(testespecial?.id == item.id ? Color.blue.opacity(0.3) : Color.clear)
                    )
                    .onTapGesture {
                    if testespecial?.id == item.id {
                        testespecial = nil
                    } else {
                        testespecial = item
                    }
                }
            }
            
            
            Button(action: {
                if let seleccionado = testespecial {
                    print("Seleccionado: \(seleccionado.nombre)")
                } else {
                    print("Nadie seleccionado")
                }
            }) {
                Text("Asignar Turno Especial")
                    .font(.system(size:25, weight: .bold))
                    .frame(width: 280)
                    .frame(height: Brand.buttonHeight)
            }
            .buttonStyle(.borderedProminent)
            .tint(Brand.primary)
            
            Spacer()
        }
    
    }
}

#Preview {
    TurnoEspecialView()
}
