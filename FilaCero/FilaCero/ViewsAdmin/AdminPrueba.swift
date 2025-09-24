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
        let urlStr = "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207/ventanillas"
        guard let url = URL(string: urlStr) else { print("URL inválida"); return }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                print("Respuesta no HTTP 2xx"); return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys

            // 1) Intenta decodificar el envelope { ok, ventanillas: [...] }
            if let envelope = try? decoder.decode(VentanillasEnvelope.self, from: data) {
                print("ok: \(envelope.ok), total: \(envelope.ventanillas.count)")
                envelope.ventanillas.forEach { v in
                    print("ID:\(v.id) Código:\(v.codigo) Activa:\(v.activa) Estado:\(v.estado.rawValue)")
                }
                return
            }

            // 2) Fallback por si algún día el backend regresa un array directo
            let list = try decoder.decode([Ventanilla].self, from: data)
            print("total: \(list.count)")
            list.forEach { v in
                print("ID:\(v.id) Código:\(v.codigo) Activa:\(v.activa) Estado:\(v.estado.rawValue)")
            }

        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }


    }

#Preview {
    AdminPrueba()
}
