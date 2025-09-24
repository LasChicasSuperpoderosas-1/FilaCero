//
//  StatusVent.swift
//  FilaCero
//
//  Created by Emilio Puga on 23/09/25.
//

import SwiftUI

struct StatusVent: View {
    let estado: VentanillaEstado
    
    var body: some View {
        HStack(spacing: 5){
            Circle().fill(estado.dotColor).frame(width: 12, height: 12)
            Text(estado.display)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(estado.textColor)
        .padding(.horizontal, 20)
        .padding(.vertical, 7)
        .background(Capsule().fill(estado.bgColor))
        
    }
}

#Preview {
    VStack(spacing: 16){
        StatusVent(estado: .APAGADA)
    }
}
