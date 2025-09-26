//
//  DashboardView.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Top 5 ventanilleros por turnos atendidos")) {
                    if vm.ventanilleros.isEmpty {
                        Text("Cargando ventanilleros...")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(vm.ventanilleros.prefix(5)) { v in
                            HStack {
                                Text(v.nombre_completo)
                                Spacer()
                                Text("\(v.total_atendidos)")
                                    .bold()
                            }
                        }
                    }
                }

                Section(header: Text("Turnos atendidos por ventanilla")) {
                    if vm.eficiencias.isEmpty {
                        Text("Cargando eficiencia...")
                            .foregroundColor(.gray)
                    } else {
                        Chart {
                            ForEach(vm.eficiencias) { e in
                                BarMark(
                                    x: .value("Ventanilla", e.ventanilla_id),
                                    y: .value("Turnos Atendidos", e.turnos_atendidos)
                                )
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.orange.opacity(0.8), Color.orange],
                                    startPoint: .bottom,
                                    endPoint: .top
                                ))
                            }
                        }
                        .frame(height: 250)
                        .padding(.vertical)
                        .chartXAxis {
                            AxisMarks(values: vm.eficiencias.map { $0.ventanilla_id }) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel {
                                    if let vent = value.as(Int.self) {
                                        Text("V\(vent)")
                                    }
                                }
                            }
                        }
                        .chartYAxisLabel("Turnos atendidos")
                        .chartXAxisLabel("Ventanilla")
                    }
                }



            }
            .navigationTitle("Estadísticas")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            vm.cargarDatosDashboard()
        }
    }
}

#Preview {
    DashboardView()
}
