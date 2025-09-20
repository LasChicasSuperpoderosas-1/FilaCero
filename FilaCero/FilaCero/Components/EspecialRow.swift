//
//  EspecialRow.swift
//  FilaCero
//
//  Created by Diego Saldaña on 19/09/25.
//

import SwiftUI

struct EspecialRow: View {
    
    @State public var testespecial: TestEspecial
    
    var body: some View {
        
        HStack(alignment: .center) {
            Text("# \(testespecial.id)")
                .font(.system(size: 25, weight: .bold, design: .default))
                .padding(.trailing, 5)
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(testespecial.nombre)")
                    .font(.system(size: 17, weight: .bold, design: .default))
                    .lineLimit(nil)
                
                Divider()
                    .padding(.vertical, 0)
                    .ignoresSafeArea()
                
                Text("Socio: #\(testespecial.socio)")
                    .font(.system(size: 17, weight: .bold, design: .default))
                    .lineLimit(nil)
            }
            .padding(.trailing, 20)
            
            Text("\(testespecial.edad) años")
                .font(.system(size: 17, weight: .bold, design: .default))
                .padding(.bottom, 30)
                
            
            Spacer()
        }
        .foregroundStyle(.black)

        
    }
}

#Preview {
    EspecialRow(testespecial: TestEspecial(id: 1, nombre: "Diego Saldaña", edad: 21, socio: 01571609))
}
