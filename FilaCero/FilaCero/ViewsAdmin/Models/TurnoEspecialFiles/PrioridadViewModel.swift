//
//  PrioridadViewModel.swift
//  FilaCero
//
//  Created by Diego Saldaña on 24/09/25.
//

import Foundation

class PrioridadViewModel: ObservableObject {
    func asignarTurnoEspecial(nombrePaciente: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207/turnos/turno_especial") else {
            print("URL inválida")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["nombre_paciente": nombrePaciente]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la llamada: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("No se recibieron datos")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Respuesta update: \(json)")
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print("Error al parsear JSON: \(error)")
                completion(false)
            }
        }
        
        task.resume()
    }
}


