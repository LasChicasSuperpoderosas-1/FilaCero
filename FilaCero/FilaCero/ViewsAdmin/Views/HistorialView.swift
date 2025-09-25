//
//  HistorialView.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import SwiftUI

// MARK: - Colores fijos
extension Color {
    static let fcGreen  = Color.green
    static let fcOrange = Color.orange
    static let fcRed    = Color.red
    static let fcGray   = Color.gray
    static let fcBlue   = Color.blue
    static let fcPurple = Color.purple
    static let fcTeal   = Color.teal
}

// MARK: - Modelos (según DDL)
enum SesionEstado: String, CaseIterable, Identifiable {
    case terminado = "TERMINADO"
    case asignado  = "ASIGNADO"
    var id: String { rawValue }
    var color: Color { self == .terminado ? .fcGreen : .fcOrange }
    var icon: String { self == .terminado ? "checkmark.circle.fill" : "clock.fill" }
}

enum TurnoEstado: String, CaseIterable, Identifiable {
    case cancelado = "CANCELADO"
    case completado = "COMPLETADO"
    case pendiente = "PENDIENTE"
    var id: String { rawValue }
    var color: Color { switch self { case .cancelado: .fcRed; case .completado: .fcGray; case .pendiente: .fcBlue } }
}

enum Prioridad: String, CaseIterable, Identifiable {
    case especial = "ESPECIAL"
    case normal   = "NORMAL"
    var id: String { rawValue }
    var color: Color { self == .especial ? .fcPurple : .fcTeal }
}

struct Atencion: Identifiable, Equatable {
    let id: Int
    let ventanillaCodigo: Int
    let folioTurno: String
    let pacienteNombre: String
    let ventanilleroNombre: String
    let sesionEstado: SesionEstado
    let turnoEstado: TurnoEstado
    let prioridad: Prioridad
    let inicio: Date
    let llamado: Date?
    let fin: Date?

    var esperaSeg: Int? { guard let llamado else { return nil }; return Int(llamado.timeIntervalSince(inicio)) }
    var servicioSeg: Int? { guard let llamado, let fin else { return nil }; return Int(fin.timeIntervalSince(llamado)) }
}

// MARK: - ViewModel
final class HistorialVentanillasVM: ObservableObject {
    @Published var items: [Atencion] = []
    @Published var filtered: [Atencion] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    // Filtros
    @Published var searchText: String = ""
    @Published var filtroVentanilla: Int? = nil
    @Published var filtroPrioridad: Prioridad? = nil
    @Published var fechaDesde: Date? = Calendar.current.date(byAdding: .day, value: -7, to: Date())
    @Published var fechaHasta: Date? = nil

    private var page: Int = 0
    private let pageSize = 30

    init(initialVentanilla: Int? = nil) {
        self.filtroVentanilla = initialVentanilla
        Task { await refresh() }
    }

    @MainActor
    func refresh() async {
        isLoading = true; error = nil; page = 0
        items = []; filtered = []
        do {
            let nuevos = try await HistorialAPI.fetch(page: page, size: pageSize)
            items = nuevos
            applyFilters()
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    @MainActor
    func loadMoreIfNeeded(current item: Atencion?) async {
        guard let item else { return }
        let thresholdIndex = filtered.index(filtered.endIndex, offsetBy: -5, limitedBy: filtered.startIndex) ?? filtered.startIndex
        if filtered.firstIndex(where: { $0.id == item.id }) == thresholdIndex { await loadNextPage() }
    }

    @MainActor
    private func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true; defer { isLoading = false }
        page += 1
        do {
            let nuevos = try await HistorialAPI.fetch(page: page, size: pageSize)
            items.append(contentsOf: nuevos)
            applyFilters()
        } catch { self.error = error.localizedDescription }
    }

    @MainActor
    func applyFilters() {
        var data = items
        if let v = filtroVentanilla { data = data.filter { $0.ventanillaCodigo == v } }
        if let p = filtroPrioridad { data = data.filter { $0.prioridad == p } }
        if let d = fechaDesde { data = data.filter { $0.inicio >= Calendar.current.startOfDay(for: d) } }
        if let h = fechaHasta { data = data.filter { $0.inicio <= (Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: h) ?? h) } }

        if !searchText.isEmpty {
            func norm(_ s: String) -> String { s.folding(options: .diacriticInsensitive, locale: .current).lowercased() }
            let q = norm(searchText)
            data = data.filter { at in
                norm(at.folioTurno).contains(q) ||
                norm(at.pacienteNombre).contains(q) ||
                norm(at.ventanilleroNombre).contains(q)
            }
        }
        filtered = data.sorted { $0.inicio > $1.inicio }
    }

    // KPIs
    var totalAtenciones: Int { filtered.count }
    var servicioPromMin: Int {
        let d = filtered.compactMap { $0.servicioSeg }.map(Double.init)
        guard !d.isEmpty else { return 0 }
        return Int(d.reduce(0,+) / Double(d.count) / 60)
    }
    var esperaPromMin: Int {
        let d = filtered.compactMap { $0.esperaSeg }.map(Double.init)
        guard !d.isEmpty else { return 0 }
        return Int(d.reduce(0,+) / Double(d.count) / 60)
    }
}

// MARK: - Vista principal
struct HistorialView: View {
    @StateObject private var vm = HistorialVentanillasVM()
    @State private var showFilters = false
    
    init(initialVentanilla: Int? = nil) {
        _vm = StateObject(wrappedValue: HistorialVentanillasVM(initialVentanilla: initialVentanilla))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let err = vm.error {
                    ErrorStateView(message: err, retry: { Task { await vm.refresh() } })
                } else if vm.isLoading && vm.filtered.isEmpty {
                    ProgressView("Cargando…").frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.filtered.isEmpty {
                    EmptyStateView(text: "Sin registros en el rango")
                } else {
                    List {
                        KPICards(total: vm.totalAtenciones, servicio: vm.servicioPromMin, espera: vm.esperaPromMin)
                            .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)

                        ForEach(daySections(vm.filtered), id: \.0) { day, rows in
                            Section(day.formatted(date: .abbreviated, time: .omitted)) {
                                ForEach(rows) { item in
                                    AtencionRow(item: item)
                                        .task { await vm.loadMoreIfNeeded(current: item) }
                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                        .listRowBackground(Color.clear)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Historial")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showFilters = true } label: { Label("Filtros", systemImage: "line.3.horizontal.decrease.circle") }
                }
            }
            .sheet(isPresented: $showFilters) { FiltrosSheet(vm: vm) }
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Folio, paciente o ventanillero")
            .onChange(of: vm.searchText) { _ in vm.applyFilters() }
            .refreshable { await vm.refresh() }
        }
    }
}

// MARK: - Row
struct AtencionRow: View {
    let item: Atencion

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.sesionEstado.icon)
                .foregroundStyle(item.sesionEstado.color)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(item.folioTurno)
                        .font(.headline)
                        .lineLimit(1)
                        .layoutPriority(2)
                    Text("· \(item.pacienteNombre)")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(1)
                    Spacer(minLength: 8)
                    Text(item.ventanilleroNombre)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text("Ventanilla \(item.ventanillaCodigo) · " + timeText(item))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack(spacing: 6) { TagChip(text: item.prioridad.rawValue, color: item.prioridad.color) }
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private func timeText(_ it: Atencion) -> String {
        it.inicio.formatted(date: .omitted, time: .shortened)
    }
}

// MARK: - Chips y KPIs
struct TagChip: View {
    let text: String
    let color: Color
    static let chipHeight: CGFloat = 24
    static let chipWidth:  CGFloat = 86
    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .frame(width: Self.chipWidth, height: Self.chipHeight)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct KPICards: View {
    let total: Int
    let servicio: Int
    let espera: Int

    var body: some View {
        HStack(spacing: 12) {
            KPI(title: "Atenciones", value: "\(total)")
            KPI(title: "Srv prom", value: "\(servicio)m")
            KPI(title: "Espera prom", value: "\(espera)m")
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct KPI: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3).bold()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Empty/Error
struct EmptyStateView: View {
    let text: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray").font(.largeTitle).foregroundStyle(.secondary)
            Text(text).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
            Text(message).multilineTextAlignment(.center)
            Button("Reintentar", action: retry)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Utils
private func daySections(_ items: [Atencion]) -> [(Date, [Atencion])] {
    let cal = Calendar.current
    let groups = Dictionary(grouping: items) { at in cal.startOfDay(for: at.inicio) }
    let keys = groups.keys.sorted(by: >)
    return keys.map { day in (day, groups[day]!.sorted { $0.inicio > $1.inicio }) }
}

// MARK: - Filtros Sheet
struct FiltrosSheet: View {
    @ObservedObject var vm: HistorialVentanillasVM
    @Environment(\.dismiss) private var dismiss

    @State private var ventanilla: Int
    @State private var prioridad: Prioridad?
    @State private var desde: Date
    @State private var usarHasta: Bool
    @State private var hastaValor: Date

    init(vm: HistorialVentanillasVM) {
        self.vm = vm
        _ventanilla = State(initialValue: vm.filtroVentanilla ?? -1)
        _prioridad = State(initialValue: vm.filtroPrioridad)
        _desde = State(initialValue: vm.fechaDesde ?? Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        _usarHasta = State(initialValue: vm.fechaHasta != nil)
        _hastaValor = State(initialValue: vm.fechaHasta ?? (vm.fechaDesde ?? Date()))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ventanilla") {
                    Picker("Código", selection: $ventanilla) {
                        Text("Todas").tag(-1)
                        ForEach(1..<21, id: \.self) { v in Text("\(v)").tag(v) }
                    }
                }
                Section("Prioridad") {
                    Picker("Prioridad", selection: $prioridad) {
                        Text("Todas").tag(nil as Prioridad?)
                        ForEach(Prioridad.allCases, id: \.self) { p in Text(p.rawValue).tag(Optional(p)) }
                    }
                }
                Section("Fechas") {
                    DatePicker("Desde", selection: $desde, displayedComponents: .date)
                    Toggle("Filtrar hasta", isOn: $usarHasta)
                    if usarHasta {
                        DatePicker("Hasta", selection: $hastaValor, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Filtros")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Limpiar") { limpiar(); aplicar(); dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Aplicar") { aplicar(); dismiss() } }
            }
        }
    }

    private func aplicar() {
        vm.filtroVentanilla = ventanilla == -1 ? nil : ventanilla
        vm.filtroPrioridad = prioridad
        vm.fechaDesde = desde
        vm.fechaHasta = usarHasta ? hastaValor : nil
        vm.applyFilters()
    }

    private func limpiar() {
        ventanilla = -1
        prioridad = nil
        desde = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        usarHasta = false
        hastaValor = desde
    }
}

// MARK: - Preview
struct HistorialVentanillasView_Previews: PreviewProvider {
    static var previews: some View { HistorialView() }
}

