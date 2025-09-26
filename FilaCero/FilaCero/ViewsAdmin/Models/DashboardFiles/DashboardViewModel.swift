//
//  DashboardViewModel.swift
//  FilaCero
//
//  Created by Angel Orlando Anguiano Peña on 25/09/25.
//

import Foundation

class DashboardViewModel: ObservableObject {
    @Published var ventanilleros: [Ventanillero] = []
    @Published var eficiencias: [Eficiencia] = []
    
    private let baseURL = "https://las-chicas-superpoderosas.tc2007b.tec.mx:10207"
    
    // Obtener ventanilleros
    func obtenerVentanilleros() {
        guard let url = URL(string: "\(baseURL)/ventanilleros/atendidos") else {
            print("URL inválida (ventanilleros)")
            return
        }
        
        print("Llamando a endpoint:", url.absoluteString)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error en la llamada ventanilleros:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de respuesta ventanilleros:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("No se recibieron datos (ventanilleros)")
                return
            }
            
            print("JSON recibido ventanilleros:",
                  String(data: data, encoding: .utf8) ?? "nil")
            
            do {
                let decodedResponse = try JSONDecoder().decode(VentanilleroResponse.self, from: data)
                DispatchQueue.main.async {
                    self.ventanilleros = decodedResponse.data
                    print("Ventanilleros decodificados:", decodedResponse.data.count)
                }
            } catch {
                print("Error de decodificación ventanilleros:", error)
            }
        }
        
        task.resume()
    }
    
    
    // Obtener eficiencia de ventanillas
    func obtenerEficiencia() {
        guard let url = URL(string: "\(baseURL)/ventanillas/eficiencia") else {
            print("URL inválida (eficiencia)")
            return
        }
        
        print("Llamando a endpoint:", url.absoluteString)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error en la llamada eficiencia:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de respuesta eficiencia:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("No se recibieron datos (eficiencia)")
                return
            }
            
            print("JSON recibido eficiencia:",
                  String(data: data, encoding: .utf8) ?? "nil")
            
            do {
                let decodedResponse = try JSONDecoder().decode(EficienciaResponse.self, from: data)
                DispatchQueue.main.async {
                    self.eficiencias = decodedResponse.data
                    print("Eficiencia decodificada:", decodedResponse.data.count)
                }
            } catch {
                print("Error de decodificación eficiencia:", error)
            }
        }
        
        task.resume()
    }

    func cargarDatosDashboard() {
        print("Cargando datos del dashboard...")
        obtenerVentanilleros()
        obtenerEficiencia()
    }
}
