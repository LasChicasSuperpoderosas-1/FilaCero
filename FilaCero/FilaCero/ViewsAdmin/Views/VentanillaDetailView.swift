import SwiftUI

struct VentanillaDetailView: View {
    let titulo: String

    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    NavigationLink {
                        //HorariosView()
                    } label: {
                        VentInfoRow(
                            icon: "clock",
                            title: "Horarios",
                            subtitle: "Configurar horarios de atención"
                        )
                    }

                    NavigationLink {
                        VentanillaSimpleView()
                    } label: {
                        VentInfoRow(
                            icon: "power",
                            title: "Habilitar/Deshabilitar",
                            subtitle: "Cambiar estado de la ventanilla"
                        )
                    }

                    NavigationLink {
                        HistorialView()
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
    }
}

#Preview {
    NavigationStack{
        VentanillaDetailView(titulo: "Ventanilla 1")
    }
}
