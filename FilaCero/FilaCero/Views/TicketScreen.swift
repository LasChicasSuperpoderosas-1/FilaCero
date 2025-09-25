import SwiftUI

struct TicketSingleScreen: View {
    let pacienteID: Int

    @State private var ticket: Ticket?
    @State private var folio: String = ""
    @State private var loading = false
    @State private var errorMsg: String?
    @State private var showTicket: Bool = true

    var body: some View {
        VStack(spacing: 20) {

            // 1) Si ya hay ticket → muestra TicketView
            if let tk = ticket {
                TicketView(data: tk, showTicket: $showTicket)
                    .onChange(of: showTicket) { _, new in
                        // Si el usuario presiona "Cancelar turno", regresa al botón
                        if new == false {
                            ticket = nil
                            folio = ""
                        }
                    }

                // Botón opcional para refrescar (GET) manualmente
                Button("Actualizar estado") {
                    Task { await doFetch() }
                }
                .buttonStyle(.bordered)

            } else {
                // 2) Pantalla inicial simple con botón
                if loading {
                    ProgressView("Generando tu turno…")
                } else if let msg = errorMsg {
                    VStack(spacing: 10) {
                        Text("Error").font(.headline)
                        Text(msg).multilineTextAlignment(.center)
                        Button("Reintentar") { Task { await doPostThenGet() } }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    Button {
                        Task { await doPostThenGet() }
                    } label: {
                        Text("Generar ticket")
                            .font(.headline)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 240)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }

    // MARK: - POST y luego GET
    private func doPostThenGet() async {
        loading = true
        errorMsg = nil
        do {
            // POST
            let creado = try await APIClient.shared.createTicket(pacienteID: pacienteID)
            // Guarda folio de 3 dígitos para el GET
            self.folio = String(format: "%03d", creado.numeroDeTurno)

            // GET (inmediato) para imprimir lo más fresco
            let consultado = try await APIClient.shared.fetchTicket(folio: folio)

            // Mostrar
            self.ticket = consultado
            self.showTicket = true
            loading = false
        } catch {
            loading = false
            errorMsg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    // MARK: - Solo GET (actualización manual)
    private func doFetch() async {
        guard !folio.isEmpty else { return }
        do {
            let consultado = try await APIClient.shared.fetchTicket(folio: folio)
            self.ticket = consultado
        } catch {
            errorMsg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

#Preview {
    TicketSingleScreen(pacienteID: 1) // usa un id_usuario ACTIVO de tu BD
}
