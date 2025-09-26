//
//  EncuestaViewModel.swift
//  FilaCero
//
//  Created by Angel Orlando Anguiano Peña on 26/09/25.
//

import Foundation

class EncuestaViewModel: ObservableObject {
    @Published var mensaje: String = ""
    
    func enviarEncuesta(encuesta: EncuestaRequest) {
        guard let url = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207/encuestas") else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let body = try JSONEncoder().encode(encuesta)
            request.httpBody = body
        } catch {
            self.mensaje = "Error al codificar JSON"
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.mensaje = "Error de conexión: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.mensaje = "No se recibió respuesta"
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(EncuestaResponse.self, from: data)
                    if decoded.status == "ok" {
                        self.mensaje = "Encuesta enviada (ID: \(decoded.data?.id_encuesta ?? 0))"
                    } else {
                        self.mensaje = "Alerta  \(decoded.msg)"
                    }
                } catch {
                    self.mensaje = "Error al procesar respuesta"
                }
            }
        }.resume()
    }
}
