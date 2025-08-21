//
//  ContentView.swift
//  FilaCero
//
//  Created by Diego Saldaña on 21/08/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image("Unknown2")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
