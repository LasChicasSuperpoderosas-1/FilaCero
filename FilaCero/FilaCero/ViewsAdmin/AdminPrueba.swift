//
//  AdminPrueba.swift
//  FilaCero
//
//  Created by Emilio Puga on 22/09/25.
//

import SwiftUI

struct AdminPrueba: View {
    var body: some View {
            VStack(spacing: 20) {
                Text("Pruebas APIs")
                    .font(.title3)

                Button("Llamar API Ventanillas") {
                    Task {
                        await callAPIVentanillas()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }

        // MARK: - Llamada API
        func callAPIVentanillas() async {
            guard let url = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207/ventanillas") else {
                print("URL inválida")
                return
            }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Respuesta no válida del servidor")
                    return
                }

                let decoder = JSONDecoder()
                let ventanillas = try decoder.decode([Ventanilla].self, from: data)

                // 👉 Aquí imprimimos cada ventanilla en consola
                for v in ventanillas {
                    print("ID: \(v.id) - Código: \(v.codigo) - Activa: \(v.activa) - Estado: \(v.estado.display)")
                }

            } catch {
                print("Error en la llamada: \(error.localizedDescription)")
            }
        }
    }

#Preview {
    AdminPrueba()
}
