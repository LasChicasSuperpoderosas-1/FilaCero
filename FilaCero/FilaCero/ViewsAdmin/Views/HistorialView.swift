//
//  HistorialView.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import SwiftUI

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
            .onChange(of: vm.searchText) { _, _ in vm.applyFilters() }
            .refreshable { await vm.refresh() }
        }
    }
}

struct HistorialVentanillasView_Previews: PreviewProvider {
    static var previews: some View { HistorialView() }
}
