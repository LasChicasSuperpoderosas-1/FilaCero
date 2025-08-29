//
//  TicketView.swift
//  FilaCero
//
//  Created by Marco de la Puente on 27/08/25.
//

import SwiftUI

struct TicketView: View {
    
   
    let data:Ticket
   
   let darkBlue: Color = Color(hue: 217/360, saturation: 83/100, brightness: 75/100)
   let darkRed: Color = Color(red: 196/255, green: 41/255, blue: 41/255)
   let offBlue: Color = Color(red: 88/255, green: 116/255, blue: 147/255)
   
   
   var body: some View {
       ZStack{
          
           Image("ticketTurno")
               .resizable(resizingMode: .stretch)
               .aspectRatio(contentMode: .fit)
               .shadow(radius: 5, y:10)
               .padding(20)
           
           VStack(spacing:8){
               Text("FARMACIA NOVA")
                   .fontWeight(.bold)
                   .font(.system(size: 30))
                   .opacity(0.5)
               Text(data.fecha)
                   .opacity(0.5)
               Text("Turno #")
               
               VStack{
                   if (data.numeroDeTurno < 10){
                       Text("00\(data.numeroDeTurno)")
                               .monospaced()
                               .font(.system(size: 50, weight: .bold))
                   }else if (data.numeroDeTurno < 100){
                       Text("0\(data.numeroDeTurno)")
                               .monospaced()
                               .font(.system(size: 50, weight: .bold))
                       }else {
                           Text("\(data.numeroDeTurno)")
                               .monospaced()
                               .font(.system(size: 50, weight: .bold))
                       }
                  
               }// <-- VSTACK NUMERO DE TURNO
               .padding(.horizontal, 10)
               .overlay(
                       RoundedRectangle(cornerRadius: 16)
                           .stroke(darkBlue, lineWidth: 1).opacity(0.8))
               .foregroundStyle(darkBlue)
               
               VStack{
                   HStack{
                       Text("PACIENTE: ")
                       Spacer()
                       Text(data.nombrePaciente)
                       
                   }//<-- HSTACK PACIENTE
                   HStack{
                       Text("HORA REGISTRO: ")
                       Spacer()
                       Text(data.horaRegistro)
                       
                   }//<-- HSTACK HORA REGISTRO
               }// <-- VSTACK PACIENTE Y HORA REGISTRO
               
               
   
               if (data.turnoActivo){
                   VStack{
                       HStack{
                           Image(systemName: "arrow.right")
                               .aspectRatio(contentMode: .fill)
                               .bold()
                               .font(.system(size: 30))
                           Text("¡ES SU TURNO!")
                               .bold()
                               .font(.system(size: 30))
                               
                           
                       }// <-- HSTACK MINI NOTIFICACION
                       .foregroundStyle(.blue)
                       
                       Text("Dirigase a ")
                       Text("VENTANILLA \(data.pantallaVentanilla)")
                           .font(.system(size:30))
                           .fontWeight(.bold)
                           .foregroundStyle(darkBlue)
                       VStack{
                           HStack{
                               Image(systemName: "clock")
                                   .fontWeight(.bold)
                                   .aspectRatio(contentMode: .fill)
                               Text("TIEMPO LÍMITE")
                                   .fontWeight(.bold)
                                   
                               
                           }// <-- HSTACK LOGO + ANUNCIO TIEMPO LIMITE
                           
                           TimerView(seconds:data.tiempoRestanteTurno, startCondition:data.turnoActivo)
                               .fontWeight(.bold)
                               .monospaced()
                               .offset(y:10)
                               .font(.system(size: 30))
                           
                       }// <-- VSTACK TIEMPO LIMITE
                       .padding(30)
                       .background(Color(red: 255/255, green: 189/255, blue: 173/255))
                       .cornerRadius(15)
                       .overlay(
                               RoundedRectangle(cornerRadius: 16)
                                   .stroke(.red, lineWidth: 1)
                           )
                       .foregroundStyle(darkRed)
                       
                   } //<-- VSTACK PANTALLA DINAMICA
                   .padding(20)
                   .frame(width: 300,height:275)
                   .background(Color(red: 173/255, green: 208/255, blue: 255/255))
                   .cornerRadius(20)
                   .overlay(
                           RoundedRectangle(cornerRadius: 16)
                               .stroke(.blue, lineWidth: 1)
                       )
               } else {
                   VStack{
                       VStack{
                           Image(systemName: "person.badge.clock.fill")
                               .aspectRatio(contentMode: .fill)
                               .bold()
                               .font(.system(size: 70))
                               .foregroundStyle(offBlue)
                               
                           
                       }// <-- HSTACK MINI NOTIFICACION
                       .foregroundStyle(.blue)
                       
       
                       Text("ESPERE SU VENTANILLA")
                           .font(.system(size:20))
                           .fontWeight(.bold)
                           .foregroundStyle(offBlue)
                       VStack{
                           HStack{
                               Image(systemName: "clock")
                                   .fontWeight(.bold)
                                   .aspectRatio(contentMode: .fill)
                               Text("TIEMPO LÍMITE")
                                   .fontWeight(.bold)
                                   
                               
                           }// <-- HSTACK LOGO + ANUNCIO TIEMPO LIMITE
                           
                           Text("5:00")
                               .fontWeight(.bold)
                               .monospaced()
                               .offset(y:10)
                               .font(.system(size: 30))
                               
                           
                       }// <-- VSTACK TIEMPO LIMITE
                       .padding(30)
                       .background(offBlue)
                       .cornerRadius(15)
                       .overlay(
                               RoundedRectangle(cornerRadius: 16)
                                   .stroke(.black, lineWidth: 1)
                           )
                       .foregroundStyle(Color(red:215/255,green:215/255,blue:215/255))
                   } //<-- VSTACK PANTALLA DINAMICA
                   .padding(20)
                   .frame(width: 300,height:275)
                   .background(Color(red: 165/255, green: 195/255, blue: 226/255))
                   .cornerRadius(20)
                   .overlay(
                           RoundedRectangle(cornerRadius: 16)
                               .stroke(offBlue, lineWidth: 1)
                       )
               }
               
               
               
               
               ZStack{
                   Rectangle()
                       .stroke(style: StrokeStyle(lineWidth: 1, dash: [10,5]))
                       .frame(width:250,height: 50)
                       .opacity(0.1)
                       .padding(2)
                   VStack{
                       Text("HORA ACTUAL").fontWeight(.bold).opacity(0.3)
                       Text("20:02:32")
                       
                   }// <-- VSTACK HORA ACTUAL
                   
               }//<--ZSTACK PARA BORDE
               
               Button("CANCELAR TURNO"){
                   print("Imma clicked")
               }
                   .padding(4)
                   .foregroundStyle(Color(red: 220/255, green: 41/255, blue: 41/255))
                   .fontWeight(.bold)
                   .frame(width:210)
                   .overlay(
                           RoundedRectangle(cornerRadius: 10)
                               .stroke(.red, lineWidth: 1)
                       )
               
               
           } // <-- VSTACK PRINCIPAL
           .padding(10)
           .frame(width:300)
           
           
           
       }// <-- ZSTACK PARA LA IMAGEN DE FONDO
   }
}
