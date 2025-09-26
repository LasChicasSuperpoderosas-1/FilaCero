import SwiftUI

struct SiguienteTurnoView: View {
    let usuarioId: Int = 21

    var nombreVentanillero: String = "Karla Esquivel"
    var nombrePaciente: String = "Pepe papa"

    @State var showAlert = false
    @State var appearTimer: Bool = false

    
    @State private var cargando = false
    @State private var mensaje = ""
    @State private var mostrarMensaje = false

    @GestureState private var isPressing = false

    var body: some View {
        GeometryReader { geometry in
            if (appearTimer == false){
                VStack (spacing: geometry.size.height * 0.02){
                    Image("LogoNova")
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.30)

                    VStack(alignment: .leading){
                        Text("Bienvenido, ")
                            .font(.system(size:geometry.size.width * 0.05))
                        +
                        Text(nombreVentanillero)
                            .font(.system(size:geometry.size.width * 0.05, weight: .bold))

                        Text("Estás atendiendo a: ")
                            .font(.system(size:geometry.size.width * 0.05))
                        +
                        Text(nombrePaciente)
                            .font(.system(size:geometry.size.width * 0.05, weight: .bold))
                    }
                    .foregroundStyle(Brand.primary)
                    .frame(maxWidth: geometry.size.width * 0.70)
                    .padding(geometry.size.height * 0.02)
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                            .stroke(Brand.primary, lineWidth: geometry.size.width * 0.005)
                    )
                    .padding(.bottom,geometry.size.height * 0.10)

                    Button(action: {
                        Task {
                            cargando = true
                            defer { cargando = false }
                            do {
                                let r = try await APICallVentanilla.abrirSesion(ventanilleroId: usuarioId)
                                mensaje = r.mensaje ?? "Sesión abierta."
                            } catch {
                                mensaje = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                            }
                            mostrarMensaje = true
                        }
                    }) {
                        Text(cargando ? "Abriendo..." : "Siguiente Turno")
                            .font(.system(size:geometry.size.width * 0.05, weight: .bold))
                            .frame(maxWidth: geometry.size.width * 0.75)
                            .frame(height: geometry.size.width * 0.15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Brand.primary)
                    .disabled(cargando)
                    .alert("Sesiones", isPresented: $mostrarMensaje) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(mensaje)
                    }

                    Button(action: {
                        if (!showAlert){
                            showAlert.toggle()
                        }
                    }) {
                        Text("Receso de 5 minutos")
                            .font(.system(size:geometry.size.width * 0.05, weight: .bold))
                            .frame(maxWidth: geometry.size.width * 0.77)
                            .frame(height: geometry.size.width * 0.10)
                    }
                    .tint(Brand.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                            .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                    )

                    if (showAlert){
                        HStack{
                            Button("Cancelar"){
                                showAlert.toggle()
                            }
                            .foregroundStyle(Brand.primary)
                            .padding(.horizontal,geometry.size.width * 0.1)
                            .padding(.vertical,geometry.size.width * 0.03)
                            .font(.system(size: geometry.size.width * 0.035))
                            .fontWeight(.bold)
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                    .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                            )
                            Spacer()
                            Button("Confirmar"){
                                showAlert.toggle()
                                appearTimer.toggle()
                            }
                            .foregroundStyle(Brand.primary)
                            .padding(.vertical,geometry.size.width * 0.03)
                            .padding(.horizontal,geometry.size.width * 0.1)
                            .font(.system(size: geometry.size.width * 0.035))
                            .fontWeight(.bold)
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                    .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                            )
                        }.frame(maxWidth: geometry.size.width * 0.77)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Brand.appBackground)
            } else  {
                VStack (alignment: .center, spacing:geometry.size.width * 0.04){
                    Text("Tiempo de receso restante")
                        .font(.system(size: geometry.size.width * 0.05))
                        .fontWeight(.bold)
                        .foregroundStyle(Brand.primary)
                        .padding(.horizontal, geometry.size.width * 0.10)
                        .padding(.vertical, geometry.size.width * 0.05)
                        .overlay(
                            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                        )
                    TimerView(seconds:5, startCondition: true , stopCondition: $appearTimer)
                        .fontWeight(.bold)
                        .monospaced()
                        .offset(y:10)
                        .font(.system(size: geometry.size.width * 0.2))
                        .foregroundStyle(Brand.primary)
                        .padding(geometry.size.width * 0.1)
                        .overlay(
                            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                .stroke(Brand.primary, lineWidth: geometry.size.width * 0.01)
                        )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Brand.appBackground)
            }
        }
    }
}
