//
//  IconBadge.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import SwiftUI

struct IconBadge: View {
    let systemName: String
    var tint: Color = .blue

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(tint.opacity(0.12))
                .frame(width: 44, height: 44)
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(tint)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
            IconBadge(systemName: "clock")
            IconBadge(systemName: "power")
            IconBadge(systemName: "clock.arrow.circlepath")
        }
        .padding()
}
