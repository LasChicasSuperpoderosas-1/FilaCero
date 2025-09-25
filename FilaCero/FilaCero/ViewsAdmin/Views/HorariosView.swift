//
//  VentanillaHorariosView.swift
//  FilaCero
//
//  Vista completa: UI + integración GET/PUT para horarios de cierre automático.
//  - GET  /ventanillas/{id}/horario_actual  → precarga toggle y hora
//  - PUT  /ventanillas/{id}/programar_cierre → guarda fin_en
//  - Persistencia local por ventanilla del “Horario semanal” (UserDefaults)
//

import SwiftUI

struct DaySchedule: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var enabled: Bool
    var start: Date
    var end: Date
}

struct VentanillaHorariosView: View {
    // Parámetros
    let ventanillaID: Int
    let windowName: String

    // MARK: - Estado: Rango de fechas (vigencia de horarios)
    @State private var usaRangoFechas = false
    @State private var fechaInicio: Date = Date()
    @State private var fechaFin: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

    // MARK: - Estado: Horario semanal (solo UI + persistencia local)
    @State private var days: [DaySchedule] = {
        let cal = Calendar.current
        func hour(_ h: Int, _ m: Int = 0) -> Date {
            var c = DateComponents()
            c.hour = h; c.minute = m
            return cal.date(from: c) ?? Date()
        }
        let names = ["Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"]
        // Por defecto: L-V 9–17 habilitado, S-D deshabilitado
        return names.enumerated().map { idx, n in
            DaySchedule(name: n, enabled: idx < 5, start: hour(9), end: hour(17))
        }
    }()

    // MARK: - Estado: Cierre automático (servidor)
    @State private var autoCloseEnabled: Bool = false
    @State private var autoCloseTime: Date = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()

    // MARK: - Estado UI
    @State private var updatedAt: Date = .now
    @State private var isSaving = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    // MARK: - Persistencia local por ventanilla
    private var storageKey: String { "horario-semanal.\(ventanillaID)" }

    private struct DayDTO: Codable {
        var name: String
        var enabled: Bool
        var sh: Int; var sm: Int
        var eh: Int; var em: Int
    }
    private struct WeeklySnapshot: Codable {
        var usaRangoFechas: Bool
        var fechaInicio: String?   // "yyyy-MM-dd"
        var fechaFin: String?      // "yyyy-MM-dd"
        var days: [DayDTO]
    }

    private func dateOnlyFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current // si tu server quiere UTC, ajustar a .utc
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
    private func hm(from d: Date) -> (Int, Int) {
        let c = Calendar.current.dateComponents([.hour, .minute], from: d)
        return (c.hour ?? 0, c.minute ?? 0)
    }
    private func time(h: Int, m: Int) -> Date {
        var comp = DateComponents()
        comp.hour = h; comp.minute = m
        return Calendar.current.date(from: comp) ?? Date()
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(windowName)
                            .font(.largeTitle.weight(.bold))
                        Spacer()
                        Label("Horarios", systemImage: "clock")
                            .font(.headline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                    }
                    Text("Configurar horarios de atención")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)

                // Info
                card {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Información")
                            .font(.title3.weight(.semibold))
                        HStack { Text("ID").foregroundColor(.secondary); Spacer(); Text("#\(ventanillaID)") }
                        HStack { Text("Nombre").foregroundColor(.secondary); Spacer(); Text(windowName) }
                        HStack(spacing: 10) {
                            Image(systemName: "clock").foregroundColor(.secondary)
                            Text("Actualizado").foregroundColor(.secondary)
                            Spacer()
                            Text(updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                        if isLoading {
                            ProgressView().padding(.top, 6)
                        }
                    }
                }

                // Rango de fechas (opcional)
                card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Rango de fechas (opcional)")
                            .font(.title3.weight(.semibold))

                        Toggle("Usar rango de vigencia", isOn: $usaRangoFechas)
                            .tint(.blue)

                        if usaRangoFechas {
                            VStack(spacing: 14) {
                                HStack {
                                    Text("Desde")
                                    Spacer()
                                    DatePicker("",
                                               selection: $fechaInicio,
                                               displayedComponents: [.date])
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                }
                                HStack {
                                    Text("Hasta")
                                    Spacer()
                                    DatePicker("",
                                               selection: $fechaFin,
                                               in: fechaInicio...,
                                               displayedComponents: [.date])
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                }
                                if fechaFin < fechaInicio {
                                    Text("La fecha final debe ser posterior a la inicial.")
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                // Horario semanal (UI + persistencia local)
                card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Horario semanal")
                            .font(.title3.weight(.semibold))

                        ForEach(days.indices, id: \.self) { i in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(days[i].name).font(.headline)
                                    Spacer()
                                    Toggle("", isOn: $days[i].enabled)
                                        .labelsHidden()
                                        .tint(.blue)
                                }
                                HStack(spacing: 16) {
                                    HStack {
                                        Text("Inicio")
                                        Spacer()
                                        DatePicker("",
                                                   selection: $days[i].start,
                                                   displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .datePickerStyle(.compact)
                                            .disabled(!days[i].enabled)
                                            .opacity(days[i].enabled ? 1 : 0.4)
                                    }
                                    HStack {
                                        Text("Fin")
                                        Spacer()
                                        DatePicker("",
                                                   selection: $days[i].end,
                                                   displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .datePickerStyle(.compact)
                                            .disabled(!days[i].enabled)
                                            .opacity(days[i].enabled ? 1 : 0.4)
                                    }
                                }
                                if days[i].enabled && days[i].end <= days[i].start {
                                    Text("La hora de fin debe ser posterior a la de inicio.")
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                }
                            }
                            if i != days.count - 1 { Divider() }
                        }
                    }
                }

                // Cierre automático
                card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Cierre automático")
                            .font(.title3.weight(.semibold))
                        Text("Programa a qué hora la ventanilla se deshabilita y se cierra la asignación del ventanillero.")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        Toggle("Activar cierre automático", isOn: $autoCloseEnabled)
                            .tint(.blue)

                        if autoCloseEnabled {
                            HStack {
                                Text("Se cerrará a")
                                Spacer()
                                DatePicker("",
                                           selection: $autoCloseTime,
                                           displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                            if autoCloseTime <= Date() && !usaRangoFechas {
                                Text("La hora debe ser posterior a la actual.")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                            Label("Al llegar la hora: 'activa'→0 y la asignación vigente se marca como finalizada.", systemImage: "info.circle")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Acciones
                card {
                    VStack(spacing: 12) {
                        Button(action: { guardarCambios() }) {
                            Text(isSaving ? "Guardando…" : "Guardar cambios")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(colors: [.blue, .blue.opacity(0.7)],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(isSaving || isLoading)

                        Button(role: .destructive) { resetToDefault() } label: {
                            Text("Restablecer por defecto")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                }

                Spacer(minLength: 12)
            }
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: { Text(alertMsg) }
        .task {
            // 1) Carga persistencia local del horario semanal
            loadWeeklyLocal()
            // 2) Carga del server el estado del auto-cierre
            loadHorario()
        }
        .onDisappear {
            // Auto-guardado local por si se sale sin tocar “Guardar cambios”
            saveWeeklyLocal()
        }
    }

    // MARK: - Lógica

    private func resetToDefault() {
        let cal = Calendar.current
        func hour(_ h: Int, _ m: Int = 0) -> Date { var c = DateComponents(); c.hour = h; c.minute = m; return cal.date(from: c) ?? Date() }
        let names = ["Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"]
        days = names.enumerated().map { idx, n in
            DaySchedule(name: n, enabled: idx < 5, start: hour(9), end: hour(17))
        }
        usaRangoFechas = false
        fechaInicio = Date()
        fechaFin = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        autoCloseEnabled = false
        autoCloseTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private func combine(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        let d = cal.dateComponents([.year, .month, .day], from: date)
        let t = cal.dateComponents([.hour, .minute, .second], from: time)
        var comp = DateComponents()
        comp.year = d.year; comp.month = d.month; comp.day = d.day
        comp.hour = t.hour; comp.minute = t.minute; comp.second = t.second
        return cal.date(from: comp) ?? date
    }

    private func parseAPIDateTime(_ s: String) -> Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let d = df.date(from: s) { return d }
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.date(from: s)
    }

    private func loadHorario() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                // Si usas SSL pinning:
                // let session = URLSession(configuration: .default,
                //                          delegate: PinnedSessionDelegate.shared,
                //                          delegateQueue: nil)
                // let r = try await APIClient.shared.getHorarioActual(ventanillaID: ventanillaID, session: session)
                let r = try await APIClient.shared.getHorarioActual(ventanillaID: ventanillaID)

                autoCloseEnabled = r.auto_cierre.enabled
                if let s = r.auto_cierre.fin_en, let d = parseAPIDateTime(s) {
                    autoCloseTime = d
                }
                updatedAt = .now
            } catch {
                alertMsg = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func guardarCambios() {
        Task {
            isSaving = true
            defer { isSaving = false }
            do {
                if autoCloseEnabled {
                    let baseDate = usaRangoFechas ? fechaInicio : Date()
                    let fin = combine(date: baseDate, time: autoCloseTime)

                    // Si usas SSL pinning:
                    // let session = URLSession(configuration: .default,
                    //                          delegate: PinnedSessionDelegate.shared,
                    //                          delegateQueue: nil)
                    // _ = try await APIClient.shared.programarCierre(ventanillaID: ventanillaID, finEn: fin, session: session)

                    _ = try await APIClient.shared.programarCierre(ventanillaID: ventanillaID, finEn: fin)
                } else {
                    // Si tu API soporta "cancelar" el cierre programado, llama aquí.
                    // p.ej., _ = try await APIClient.shared.cancelarCierre(ventanillaID: ventanillaID)
                }

                // Persistencia local del horario semanal y rango de fechas
                saveWeeklyLocal()

                updatedAt = .now
                alertMsg = "Cambios guardados correctamente."
                showAlert = true
            } catch {
                alertMsg = error.localizedDescription
                showAlert = true
            }
        }
    }

    // MARK: - Persistencia local (UserDefaults)

    private func saveWeeklyLocal() {
        let df = dateOnlyFormatter()
        let payload = WeeklySnapshot(
            usaRangoFechas: usaRangoFechas,
            fechaInicio: usaRangoFechas ? df.string(from: fechaInicio) : nil,
            fechaFin:     usaRangoFechas ? df.string(from: fechaFin)     : nil,
            days: days.map { d in
                let (sh, sm) = hm(from: d.start)
                let (eh, em) = hm(from: d.end)
                return DayDTO(name: d.name, enabled: d.enabled, sh: sh, sm: sm, eh: eh, em: em)
            }
        )
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadWeeklyLocal() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(WeeklySnapshot.self, from: data) else { return }

        usaRangoFechas = snapshot.usaRangoFechas
        if let s = snapshot.fechaInicio, let d = dateOnlyFormatter().date(from: s) { fechaInicio = d }
        if let s = snapshot.fechaFin, let d = dateOnlyFormatter().date(from: s) { fechaFin = d }

        var rebuilt: [DaySchedule] = []
        for dto in snapshot.days {
            rebuilt.append(
                DaySchedule(
                    name: dto.name,
                    enabled: dto.enabled,
                    start: time(h: dto.sh, m: dto.sm),
                    end:   time(h: dto.eh, m: dto.em)
                )
            )
        }
        if !rebuilt.isEmpty { days = rebuilt }
    }

    // MARK: - Card helper
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content().padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 6)
        .padding(.horizontal, 20)
    }
}

#Preview("iPhone 15 Pro") {
    NavigationStack {
        VentanillaHorariosView(
            ventanillaID: 2,
            windowName: "Ventanilla 2"
        )
    }
}
