//
//  SiguienteTurnoView.swift
//  FilaCero
//
//  Created by Marco de la Puente on 20/09/25.
//

import SwiftUI

struct SiguienteTurnoView: View {
    var nombreVentanillero: String = "Juan Pérez"
    var nombrePaciente: String = "Pepe papa"
    @State var showAlert = false
    @State var appearTimer: Bool = false
    
    @GestureState private var isPressing = false
    
    var body: some View {
        
        //Permite tamaños dinámicos de acuerdo al tamaño de la view que encapsula
        GeometryReader { geometry in
            
            if (appearTimer == false){
                VStack (spacing: geometry.size.height * 0.02){
                  
                    VStack(alignment: .leading){
                        Text("Bienvenido, ")
                            .font(.system(size:geometry.size.width * 0.05))
                        +
                        Text(nombreVentanillero)
                            .font(.system(size:geometry.size.width * 0.05, weight: .bold))
                        
                        Text("Estás atendiendo a: ")
                            .font(.system(size:geometry.size.width * 0.05))
                        +
                        Text(nombrePaciente)
                            .font(.system(size:geometry.size.width * 0.05, weight: .bold))
                        
                        
                    } // <-- VSTACK GENERAL BLOQUE DE INFO VENTANILLERO Y PACIENTE
                    
                        .foregroundStyle(Brand.primary)
                        .frame(maxWidth: geometry.size.width * 0.70)
                        .padding(geometry.size.height * 0.02)
                        .overlay(
                            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                .stroke(Brand.primary, lineWidth: geometry.size.width * 0.005)
                            
                        )
                        .padding(.bottom,geometry.size.height * 0.10)
                    
                    
                    
                    
                    Button(action: {
                        print("clicked")
                    }) {
                        Text("Siguiente Turno")
                            .font(.system(size:geometry.size.width * 0.05, weight: .bold))
                            .frame(maxWidth: geometry.size.width * 0.75)
                            .frame(height: geometry.size.width * 0.15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Brand.primary)
                    
                    
                    
                    Button(action: {
                        if (!showAlert){
                            showAlert.toggle()
                        }
                    }) {
                        Text("Receso de 5 minutos")
                            .font(.system(size:geometry.size.width * 0.05, weight: .bold))
                            .frame(maxWidth: geometry.size.width * 0.77)
                            .frame(height: geometry.size.width * 0.10)
                    }
                    /*
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 1.5)
                            .updating($isPressing) { currentState, gestureState, _ in
                                gestureState = currentState
                            }
                            .onEnded { _ in
                                appearTimer.toggle()
                            }
                    )
                     */
                    .tint(isPressing ? Brand.primary : Brand.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                            .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                    )
                    
                    /*
                    .alert("CONFIRMACIÓN", isPresented: $showAlert) {
                        Button("Confirmar", role: .destructive) {
                            appearTimer.toggle()
                            // Handle deletion logic here
                        }
                        Button("Cancelar", role: .cancel) {}
                    }
                     */
                    
                    if (showAlert){
                        HStack{
                            Button("Cancelar"){
                                showAlert.toggle()
                            }
                            .foregroundStyle(Brand.primary)
                            
                            .padding(.horizontal,geometry.size.width * 0.1)
                            .font(.system(size: geometry.size.width * 0.04))
                            .fontWeight(.bold)
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                    .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                            )
                            Spacer()
                            
                            Button("Confirmar"){
                                showAlert.toggle()
                                appearTimer.toggle()
                            }   .foregroundStyle(Brand.primary)
                            
                                .padding(.horizontal,geometry.size.width * 0.1)
                                .font(.system(size: geometry.size.width * 0.04))
                                .fontWeight(.bold)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                        .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                                )
                        }.frame(maxWidth: geometry.size.width * 0.77)
                    }
                     
                   
                    
                } //VSTACK GENERAL
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Brand.appBackground)
            } else  {
               
                
                VStack (alignment: .center, spacing:geometry.size.width * 0.04){
                    Text("Tiempo de receso restante")
                        .font(.system(size: geometry.size.width * 0.05))
                        .fontWeight(.bold)
                        .foregroundStyle(Brand.primary)
                        .padding(.horizontal, geometry.size.width * 0.10)
                        .padding(.vertical, geometry.size.width * 0.05)
                        .overlay(
                            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                        )
                        
                    TimerView(seconds:5, startCondition: true , stopCondition: $appearTimer)
                        .fontWeight(.bold)
                        .monospaced()
                        .offset(y:10)
                        .font(.system(size: geometry.size.width * 0.2))
                        .foregroundStyle(Brand.primary)
                        .padding(geometry.size.width * 0.1)
                        .overlay(
                            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                        )
                }//Vstack de botón
                .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Brand.appBackground)
                
                
             
                
            }
            
          
            
            
            
        }//GEOMETRYVIEW
    }
}

#Preview {
    SiguienteTurnoView()
}


