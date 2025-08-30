//
//  EncuestaView.swift
//  EncuestaNova
//
//  Created by Angel Orlando Anguiano Peña on 28/08/25.
//

import SwiftUI

struct EncuestaView: View {
    
    @State private var MedicineResponse: Int? = nil
    @State private var comment: String = ""
    @State var selectedStar: Int = -1
    @State private var showAlertStars: Bool = false
    @State private var showAlertMedicines: Bool = false
    @State public var showMain = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            //Logo
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
            
            // Spacer()
            
            VStack(alignment: .leading){
                
                //Spacer()

                Text("Califique su experiencia usando esta aplicación de turnos")
                    .padding(.top, 30)
                    .padding(.horizontal, 22)
                    .multilineTextAlignment(.leading)
                       .lineLimit(nil)
                       .fixedSize(horizontal: false, vertical: true)
        
                //Estrellas de calificación
                HStack(spacing: 5){
                    ForEach(0..<5){i in
                         Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 60, height: 65)
                            .padding(.horizontal,4)
                            .foregroundColor(self.selectedStar >= i ? .yellow : .gray)
                            .onTapGesture {
                                self.selectedStar = i
                            }
                    }
                }
                .padding(.horizontal, 20)

                Text("¿Encontró en farmacia todos los medicamentos indicados en su receta médica?")
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 30)
                    .padding(.horizontal, 22)
                Picker(selection: $MedicineResponse, label: Text("Picker")) {
                    Text("No").tag(1)
                    Text("Sí").tag(2)
                }
                .font(.system(size:30))
                .pickerStyle(.palette)
                .frame(height: 35)
                .padding(.top, 4)
                .padding(.horizontal, 22)
                .padding(.bottom, 25)
                
                Text("Comentario adicional")
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 22)
                TextEditor(text: $comment)
                    .frame(width: 300, height: 120)
                    .padding(.horizontal, 30)
                    .padding(.top, 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                
                HStack(alignment: .center, spacing: 4){
                    Button("Cancelar"){
                        dismiss()
                    }
                    .font(.system(size:30, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: Brand.buttonHeight)
                    .buttonStyle(.borderedProminent)
                    .tint(Color .gray)
                    
                    Button("Enviar"){
                        if selectedStar == -1 {
                            showAlertStars.toggle()
                        } else if MedicineResponse == nil {
                            showAlertMedicines.toggle()
                        } else {
                            print("Respuesta enviada")
                        }
                    }
                    .font(.system(size:30, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: Brand.buttonHeight)
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 255/255, green: 153/255, blue: 0/255))
                    .alert("Por favor deja una calificación", isPresented: $showAlertStars) {
                        Button("OK") {}
                    }
                    .alert("Por favor responde sobre los medicamentos", isPresented: $showAlertMedicines) {
                        Button("OK") {}
                    }
                    .disabled(selectedStar == -1 || MedicineResponse == nil)
                    
                } //fin del hstack
                .padding(.top, 25)
                .padding(.leading,10)
            } //fin del vstack
        }
    }
}

#Preview {
    EncuestaView()
}
