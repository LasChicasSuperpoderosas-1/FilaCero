//
//  EncuestaView.swift
//  EncuestaNova
//
//  Created by Angel Orlando Anguiano Peña on 28/08/25.
//

import SwiftUI

class UserSession {
    static let shared = UserSession()
    private init() {}
    
    var usuarioActual: MiUsuario?
    var sesionActual: MiSesion?
}

struct MiUsuario {
    let id_usuario: Int
    let nombre: String
}

struct MiSesion {
    let id_sesion: Int
    let fecha_inicio: Date
}

struct EncuestaView: View {
    @StateObject private var vm = EncuestaViewModel()
    
    @State private var selectedStar: Int = -1
    @State private var MedicineResponse: Int? = nil
    @State private var comment: String = ""
    
    @State private var showAlertStars: Bool = false
    @State private var showAlertMedicines: Bool = false
    @State private var showAlertSuccess: Bool = false // Nueva alerta
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    Image("LogoNova")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                    
                    Text("Encuesta de satisfacción")
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading) {
                        
                        Text("Califique su experiencia usando esta aplicación de turnos")
                            .padding(.top, 30)
                            .padding(.horizontal, 24)
                        
                        HStack(spacing: 5) {
                            ForEach(0..<5) { i in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(selectedStar >= i ? .yellow : .gray)
                                    .onTapGesture { selectedStar = i }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Text("¿Encontró en farmacia todos los medicamentos indicados en su receta médica?")
                            .padding(.top, 30)
                            .padding(.horizontal, 24)
                        
                        Picker(selection: $MedicineResponse, label: Text("Picker")) {
                            Text("No").tag(1)
                            Text("Sí").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 24)
                        
                        Text("Comentario adicional")
                            .padding(.top, 20)
                            .padding(.horizontal, 24)
                        
                        TextEditor(text: $comment)
                            .frame(height: 120)
                            .padding(.horizontal, 24)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                        
                        HStack {
                            Button("Cancelar") {
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.gray)
                            .frame(maxWidth: .infinity)
                            
                            Button("Enviar") {
                                if selectedStar == -1 {
                                    showAlertStars.toggle()
                                } else if MedicineResponse == nil {
                                    showAlertMedicines.toggle()
                                } else {
                                    enviarEncuesta()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.orange)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 20)
                    }
                }
            }
        }
        .alert("Por favor deja una calificación", isPresented: $showAlertStars) {
            Button("OK") {}
        }
        .alert("Por favor responde sobre los medicamentos", isPresented: $showAlertMedicines) {
            Button("OK") {}
        }
        .alert("¡Encuesta enviada correctamente!", isPresented: $showAlertSuccess) {
            Button("OK") {}
        }
    }
    
    private func enviarEncuesta() {
        let pacienteId = UserSession.shared.usuarioActual?.id_usuario ?? 1
        let sesionId = UserSession.shared.sesionActual?.id_sesion ?? 10
        
        let encuesta = EncuestaRequest(
            paciente_id: pacienteId,
            sesion_id: sesionId,
            calificacion: selectedStar + 1,
            encontro_medicamentos: MedicineResponse == 2,
            comentario: comment
        )
        
        // Llamada al ViewModel
        vm.enviarEncuesta(encuesta: encuesta)
        
        // Mostrar alerta de envio correcto
        showAlertSuccess = true
    }
}

struct EncuestaView_Previews: PreviewProvider {
    static var previews: some View {
        EncuestaView()
    }
}
