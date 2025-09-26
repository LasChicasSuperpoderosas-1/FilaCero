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
        currentTask?.cancel()

        isLoading = true
        errorMessage = nil

        currentTask = Task {
            do {
                let items = try await APIClient.shared.fetchVentanillas(activas: activas)
                if Task.isCancelled { return }
                self.ventanillas = items
            } catch {
                if let urlErr = error as? URLError, urlErr.code == .cancelled { return }
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}


