//
//  HistorialVentanillaComp.swift
//  FilaCero
//
//  Created by Jordy Granados on 25/09/25.
//

import SwiftUI
import Foundation

extension Color {
    static let fcGreen  = Color.green
    static let fcOrange = Color.orange
    static let fcRed    = Color.red
    static let fcGray   = Color.gray
    static let fcBlue   = Color.blue
    static let fcPurple = Color.purple
    static let fcTeal   = Color.teal
}

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
    var color: Color {
        switch self {
        case .cancelado: .fcRed
        case .completado: .fcGray
        case .pendiente: .fcBlue
        }
    }
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

    var esperaSeg: Int? {
        guard let llamado else { return nil }
        return Int(llamado.timeIntervalSince(inicio))
    }
    var servicioSeg: Int? {
        guard let llamado, let fin else { return nil }
        return Int(fin.timeIntervalSince(llamado))
    }
}

func daySections(_ items: [Atencion]) -> [(Date, [Atencion])] {
    let cal = Calendar.current
    let groups = Dictionary(grouping: items) { at in cal.startOfDay(for: at.inicio) }
    let keys = groups.keys.sorted(by: >)
    return keys.map { day in (day, groups[day]!.sorted { $0.inicio > $1.inicio }) }
}

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
                HStack(spacing: 6) {
                    TagChip(text: item.prioridad.rawValue, color: item.prioridad.color)
                }
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private func timeText(_ it: Atencion) -> String {
        it.inicio.formatted(date: .omitted, time: .shortened)
    }
}

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
                        ForEach(Prioridad.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(Optional(p))
                        }
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Limpiar") { limpiar(); aplicar(); dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") { aplicar(); dismiss() }
                }
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
