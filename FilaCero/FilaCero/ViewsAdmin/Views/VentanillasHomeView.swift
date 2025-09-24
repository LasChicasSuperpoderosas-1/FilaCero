//
//  VentanillasHomeView.swift
//  FilaCero
//
//  Created by Emilio Puga on 23/09/25.
//

import SwiftUI

struct VentanillasHomeView: View {
    @StateObject private var vm = VentanillasVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image("LogoNova")
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 212)
                    Text("Sistema de Ventanillas")
                        .foregroundStyle(Color(red:102/255, green: 102/255, blue: 102/255)) //Hex: #666666
                        .bold()
                        .font(.system(size:20))
                        .padding(.bottom, 40)
                    
                    if let msg = vm.errorMessage {
                        Text(msg).foregroundStyle(.red).font(.footnote)
                    }

                    ForEach(vm.ventanillas) { v in
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
            .navigationTitle("") // opcional
            .toolbar(.hidden, for: .navigationBar) // si quieres el look limpio
            .refreshable { await vm.load() }   // pull to refresh
            .task { await vm.load() }
        }
    }
}

#Preview {
    VentanillasHomeView()
}
