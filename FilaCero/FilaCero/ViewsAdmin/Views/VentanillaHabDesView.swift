//
//  VentanillaHabDesView.swift
//  FilaCero
//
//  Created by Emilio Puga on 22/09/25.
//

import SwiftUI

struct VentanillaSimpleView: View {
    // Datos de la ventanilla (ajústalos según tu caso)
    @State private var windowId: Int = 7
    @State private var windowName: String = "Ventanilla 7"
    @State private var isEnabled: Bool = true
    @State private var updatedAt: Date = .now

    // Estado de UI
    @State private var isLoading = false
    @State private var showDisableConfirm = false
    @State private var showError = false
    @State private var errorMsg = ""

    private var statusLabel: String { isEnabled ? "Libre" : "Deshabilitada" }
    private var statusColor: Color  { isEnabled ? .green : .red }

    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(windowName)
                            .font(.title2.weight(.semibold))
                        Spacer()
                        HStack(spacing: 8) {
                            Circle().fill(statusColor).frame(width: 12, height: 12)
                            Text(statusLabel).font(.headline.weight(.semibold))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                    }
                    Text("Habilitar / Deshabilitar")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.top, 10).padding(.horizontal, 20)

                // Card: Información
                VStack(alignment: .leading, spacing: 16) {
                    Text("Información").font(.title3.weight(.semibold))
                    infoRow("ID", "#\(windowId)")
                    infoRow("Nombre", windowName)
                    infoRow("Estado", statusLabel)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 6)
                .padding(.horizontal, 20)

                // Card: Control
                VStack(alignment: .leading, spacing: 20) {
                    Text("Control de ventanilla").font(.title3.weight(.semibold))

                    Button {
                        guard !isLoading else { return }
                        if isEnabled {
                            showDisableConfirm = true
                        } else {
                            Task { await cambiarEstado(true) }
                        }
                    } label: {
                        HStack(spacing: 14) {
                            if isLoading {
                                ProgressView().progressViewStyle(.circular).tint(.white)
                            } else {
                                Image(systemName: isEnabled ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 26, weight: .semibold))
                            }
                            Text(isEnabled ? "Deshabilitar ventanilla" : "Habilitar ventanilla")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .foregroundColor(isEnabled ? .red : .white)
                        .background(
                            isEnabled
                            ? LinearGradient(colors: [.red.opacity(0.16), .red.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [.blue, .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isEnabled ? Color.red.opacity(0.35) : .clear, lineWidth: isEnabled ? 1.5 : 0)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(isLoading)

                    Divider()

                    HStack(spacing: 10) {
                        Image(systemName: "clock").foregroundColor(.secondary)
                        Text("Actualizado").foregroundColor(.secondary)
                        Spacer()
                        Text(updatedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    .font(.body)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 6)
                .padding(.horizontal, 20)

                Spacer(minLength: 20)
            }
        }
        // Confirmación para deshabilitar
        .confirmationDialog("Pausar atenciones",
                            isPresented: $showDisableConfirm,
                            titleVisibility: .visible) {
            Button("Deshabilitar ventanilla", role: .destructive) {
                Task { await cambiarEstado(false) }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Mientras esté deshabilitada no se asignarán turnos.")
        }
        // Alert de error
        .alert("No se pudo actualizar", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMsg)
        }
    }

    // MARK: - Llamada al endpoint desde la vista
    @MainActor
    func cambiarEstado(_ value: Bool) async {
        isLoading = true
        showError = false
        errorMsg = ""

        do {
            let estadoFinal = try await VentanillaHabDesAPI.cambiarEstado(ventanillaId: windowId, activa: value)
            isEnabled  = estadoFinal                 // lo que quedó en el server (o lo enviado)
            // Si tu server no regresa nombre/código, no lo toques:
            // windowName = windowName
            updatedAt  = .now
        } catch {
            showError = true
            errorMsg  = error.localizedDescription
        }

        isLoading = false
    }

    // (Opcional) alias para compatibilidad si antes llamabas setActiva(_:)
    func setActiva(_ value: Bool) async { await cambiarEstado(value) }

    // MARK: - Fila simple
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).foregroundColor(.primary)
        }
        .font(.body)
    }
}

#Preview {
    VentanillaSimpleView()
}
