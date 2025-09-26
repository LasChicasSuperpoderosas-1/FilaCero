//
//  TicketAnimationView.swift
//  FilaCero
//
//  Created by Emilio Puga on 27/08/25.
//

// VISTA PARA PACIENTE

import SwiftUI

struct TicketAnimationView: View {
    // Configura aquí el paciente que generará el ticket
    let pacienteID: Int = 1   // <-- usa un id_usuario ACTIVO en tu BD

    @State private var posicionInicial: CGFloat = -820
    @State private var controlAnimacion = false

    // Ticket que consume tu TicketView (empieza vacío; se llena tras POST+GET)
    @State private var ticket: Ticket?

    // Backend
    @State private var folio: String = ""      // "NNN" para /getTurnos/{folio}
    @State private var loading = true
    @State private var errorMsg: String?

    @Binding public var showTicket: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    if let tk = ticket {
                        TicketView(data: tk, showTicket: $showTicket)
                            .frame(width: 400)
                            .offset(y: posicionInicial)
                            .onAppear { iniciarAnimacion() }
                    } else if loading {
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("Generando tu turno…")
                                .font(.headline)
                        }
                        .frame(height: 400)
                    } else if let msg = errorMsg {
                        VStack(spacing: 12) {
                            Text("Error").font(.headline)
                            Text(msg).multilineTextAlignment(.center)
                            Button("Reintentar") { Task { await bootstrap() } }
                                .buttonStyle(.borderedProminent)
                        }
                        .frame(height: 400)
                    }
                }

                Spacer()

                if ticket != nil {
                    HStack {
                        NavigationLink("Encuesta") {
                            EncuestaView()
                                .navigationBarBackButtonHidden(true)
                        }
                        Button("prueba turno") {
                            // Simulación local de "llamado"
                            guard var tk = ticket else { return }
                            tk.turnoActivo.toggle()
                            tk.pantallaAnuncioSuperior = tk.turnoActivo ? "¡ES SU TURNO!" : "ESPERE SU VENTANILLA"
                            ticket = tk
                        }
                    }
                    .padding()
                    .clipShape(.buttonBorder)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await bootstrap() }   // POST + GET al entrar
    }

    // MARK: - POST y luego GET
    private func bootstrap() async {
        loading = true
        errorMsg = nil
        do {
            // 1) POST: crear ticket
            let creado = try await APIClient.shared.createTicket(pacienteID: pacienteID)
            // Guarda el folio de 3 dígitos para el GET
            folio = String(format: "%03d", creado.numeroDeTurno)

            // 2) GET inmediato para imprimirlo con datos más frescos
            let consultado = try await APIClient.shared.fetchTicket(folio: folio)

            // 3) Mostrar en la UI
            ticket = consultado
            loading = false

            // 4) Disparar animación de entrada
            iniciarAnimacion()
        } catch {
            loading = false
            errorMsg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    // MARK: - Animación (tu misma coreografía)
    private func iniciarAnimacion() {
        withAnimation(.none) { posicionInicial = -820 }

        withAnimation(.easeIn(duration: 1.6).delay(0.2)) {
            posicionInicial = -180
        }

        withAnimation(.linear(duration: 0.30).delay(2.25)) {
            posicionInicial = -310
        }

        withAnimation(.linear(duration: 0.45).delay(2.75)) {
            posicionInicial = -180
        }

        withAnimation(.interpolatingSpring(stiffness: 220, damping: 15).delay(2.30)) {
            posicionInicial = 0
        }
    }

    private func reiniciarAnimacion() {
        posicionInicial = -820
        iniciarAnimacion()
    }
}

#Preview {
    TicketAnimationView(showTicket: .constant(true))
}
