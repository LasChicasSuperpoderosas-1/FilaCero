//
//  HistorialVentanillasVM.swift
//  FilaCero
//
//  Created by Jordy Granados on 25/09/25.
//

import Foundation

final class HistorialVentanillasVM: ObservableObject {
    @Published var items: [Atencion] = []
    @Published var filtered: [Atencion] = []
    @Published var isLoading = false
    @Published var error: String? = nil

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
