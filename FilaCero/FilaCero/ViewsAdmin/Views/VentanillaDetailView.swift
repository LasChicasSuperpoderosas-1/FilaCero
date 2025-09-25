import SwiftUI

struct VentanillaDetailView: View {
    let titulo: String
    let ventanillaId: Int
    let initialEnabled: Bool

    @Environment(\.dismiss) private var dismiss   // 👈 para cerrar la vista

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                NavigationLink {
                    VentanillaHorariosView(ventanillaID: ventanillaId, windowName: titulo)
                } label: {
                    VentInfoRow(
                        icon: "clock",
                        title: "Horarios",
                        subtitle: "Configurar horarios de atención"
                    )
                }

                NavigationLink {
                    VentanillaSimpleView(ventanillaID: ventanillaId, windowName: titulo, initialEnabled: initialEnabled)
                } label: {
                    VentInfoRow(
                        icon: "power",
                        title: "Habilitar/Deshabilitar",
                        subtitle: "Cambiar estado de la ventanilla"
                    )
                }

                NavigationLink {
                    HistorialView(initialVentanilla: ventanillaId)
                } label: {
                    VentInfoRow(
                        icon: "clock.arrow.circlepath",
                        title: "Historial",
                        subtitle: "Ver historial de atenciones"
                    )
                }
            }
            .padding()
        }
        .navigationTitle(titulo)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)          // 👈 ocultar back por defecto
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Volver")
                    }
                }
                .buttonStyle(.plain)                   // mantiene estilo nativo
                .tint(.blue)                          // opcional: color del botón
                .accessibilityLabel("Volver")
            }
        }
    }
}

#Preview {
    NavigationStack {
        VentanillaDetailView(titulo: "Ventanilla 1", ventanillaId: 1, initialEnabled: false)
    }
}
