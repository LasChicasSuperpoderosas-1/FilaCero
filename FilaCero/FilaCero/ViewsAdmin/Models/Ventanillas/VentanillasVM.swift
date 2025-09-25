//
//  VentanillasVM.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import Foundation

@MainActor
final class VentanillasVM: ObservableObject {
    @Published var ventanillas: [Ventanilla] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentTask: Task<Void, Never>?

    func load(activas: Bool? = nil) {
        // cancela la request anterior si sigue viva
        currentTask?.cancel()

        isLoading = true
        errorMessage = nil

        currentTask = Task {
            do {
                let items = try await APIClient.shared.fetchVentanillas(activas: activas)
                // si la tarea fue cancelada en medio, no toques estado
                if Task.isCancelled { return }
                self.ventanillas = items
            } catch {
                // si fue cancelación (-999), no muestres error
                if let urlErr = error as? URLError, urlErr.code == .cancelled { return }
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}


