//
//  TurnoEspecialViewModel.swift
//  FilaCero
//
//  Created by Diego Saldaña on 24/09/25.
//

import Foundation

class TurnoEspecialViewModel: ObservableObject {
    @Published var listaEspecial: [TurnoEspecial] = []

    func obtenerTurnosDesdeAPI() {
        guard let url = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207/turnos") else {
            print("URL inválida")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error en la llamada: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No se recibieron datos")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TurnosResponse.self, from: data)
                DispatchQueue.main.async {
                    self.listaEspecial = decodedResponse.turnos.map {
                        TurnoEspecial(
                            id: $0.folio_turno,
                            nombre: $0.nombre_completo,
                            estado: $0.estado,
                            prioridad: $0.prioridad
                        )
                    }
                }
            } catch {
                print("Error de decodificación: \(error)")
            }
        }

        task.resume()
    }
}


