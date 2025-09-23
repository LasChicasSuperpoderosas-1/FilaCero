//
//  VentanillasHomeView.swift
//  FilaCero
//
//  Created by Emilio Puga on 23/09/25.
//

import SwiftUI

struct VentanillasHomeView: View {
    let ventanillas: [Ventanilla]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    ForEach(ventanillas) { v in
                        NavigationLink {
                            VentanillaDetailView(titulo: v.titulo)
                        } label: {
                            VentanillaRowCard(ventanilla: v)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .navigationTitle("Inicio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let sample: [Ventanilla] = [
        .init(id: 1, codigo: 1, activa: false, estado: .APAGADA),
        .init(id: 2, codigo: 2, activa: true,  estado: .LIBRE),
        .init(id: 3, codigo: 3, activa: true,  estado: .OCUPADA),
        .init(id: 4, codigo: 4, activa: true,  estado: .RECESO)
    ]
    
    VentanillasHomeView(ventanillas: sample)
}
