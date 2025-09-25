//
//  TicketScreen.swift
//  FilaCero
//
//  Created by Emilio Puga on 25/09/25.
//

import SwiftUI

struct TicketScreen: View {
    let pacienteID: Int

    // Modelo que traes del API
    @State private var ticketAPI: TicketModelApi?
    // Modelo que consume TicketView
    @State private var ticketUI: Ticket?
    @State private var showTicket = true

    @State private var folio: String = ""
    @State private var loading = true
    @State private var errorMsg: String?

    // Polling cada 5 s
    @State private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if let tk = ticketUI, showTicket {
                TicketView(data: tk, showTicket: $showTicket)
                    .onReceive(timer) { _ in
                        Task { await refresh() }
                    }
            } else if loading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Generando tu turno…")
                        .font(.headline)
                }
            } else if let msg = errorMsg {
                VStack(spacing: 12) {
                    Text("Error").font(.headline)
                    Text(msg).multilineTextAlignment(.center)
                    Button("Reintentar") { Task { await bootstrap() } }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                Text("No se encontró ticket")
                    .foregroundColor(.secondary)
            }
        }
        .task { await bootstrap() }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }

    // MARK: - Crear ticket (POST)
    private func bootstrap() async {
        loading = true
        errorMsg = nil
        do {
            let apiTicket = try await APIClient.shared.createTicket(pacienteID: pacienteID)
            self.ticketAPI = apiTicket
            self.ticketUI  = mapToUI(apiTicket)
            self.folio     = String(format: "%03d", apiTicket.numeroDeTurno)
            loading = false
            await refresh() // primer refresh inmediato
        } catch {
            loading = false
            errorMsg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    // MARK: - Refrescar estado (GET por folio)
    @MainActor
    private func refresh() async {
        guard !folio.isEmpty else { return }
        do {
            let updated = try await APIClient.shared.fetchTicket(folio: folio)
            self.ticketAPI = updated
            self.ticketUI  = mapToUI(updated)
        } catch {
            // silencio el error de poll para no romper UI
        }
    }

    // MARK: - Mapper: TicketModelApi -> Ticket (modelo que usa TicketView)
    private func mapToUI(_ dto: TicketModelApi) -> Ticket {
        Ticket(
            numeroDeTurno: dto.numeroDeTurno,
            nombrePaciente: dto.nombrePaciente, pantallaAnuncioSuperior: "String",
            pantallaVentanilla: dto.pantallaVentanilla,
            turnoActivo: dto.turnoActivo,
            tiempoRestanteTurno: dto.tiempoRestanteTurno
        )
    }
}

#Preview {
    TicketScreen(pacienteID: 21)
}
