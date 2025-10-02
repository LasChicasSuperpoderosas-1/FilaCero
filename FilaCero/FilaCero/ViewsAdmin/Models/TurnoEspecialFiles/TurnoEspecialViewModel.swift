//
//  TurnoEspecialViewModel.swift
//  FilaCero
//
//  Created by Diego Saldaña on 24/09/25.
//

import Foundation

class TurnoEspecialViewModel: ObservableObject {
    @Published var listaEspecial: [TurnoEspecial] = []
    @Published var errorMessage: String? = nil

    func obtenerTurnosDesdeAPI() {
        guard let url = URL(string: "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207/turnos") else {
            DispatchQueue.main.async {
                self.errorMessage = "URL inválida"
                self.listaEspecial = []
            }
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error al conectar con el servidor: \(error.localizedDescription)"
                    self.listaEspecial = []
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No se recibieron datos"
                    self.listaEspecial = []
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TurnosResponse.self, from: data)
                DispatchQueue.main.async {
                    if decodedResponse.ok {
                        self.listaEspecial = decodedResponse.turnos.map {
                            TurnoEspecial(
                                id: $0.folio_turno,
                                nombre: $0.nombre_completo,
                                estado: $0.estado,
                                prioridad: $0.prioridad
                            )
                        }
                        self.errorMessage = nil
                    } else {
                        self.listaEspecial = []
                        self.errorMessage = "Lista no cargada"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error de decodificación"
                    self.listaEspecial = []
                }
            }
        }

        task.resume()
    }
}
