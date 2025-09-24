//
//  HorariosView.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

//
//  VentanillaHorariosView.swift
//  FilaCero
//
//  UI SOLO FRONT en un cuerpo simple (un solo VStack) para establecer horarios y rango de fechas.
//  Sin backend todavía. Estilo limpio con tarjetas sencillas como tu vista de Habilitar/Deshabilitar.
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
    let ventanillaID: Int
    let windowName: String

    @State private var usaRangoFechas = false
    @State private var fechaInicio: Date = Date()
    @State private var fechaFin: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

    @State private var days: [DaySchedule] = {
        let cal = Calendar.current
        func hour(_ h: Int, _ m: Int = 0) -> Date {
            var c = DateComponents(); c.hour = h; c.minute = m
            return cal.date(from: c) ?? Date()
        }
        let names = ["Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"]
        return names.enumerated().map { idx, n in
            DaySchedule(name: n, enabled: idx < 5, start: hour(9), end: hour(17))
        }
    }()

    @State private var updatedAt: Date = .now
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Encabezado
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(windowName)
                            .font(.largeTitle.weight(.bold))
                        Spacer()
                        Label("Horarios", systemImage: "clock")
                            .font(.headline.weight(.semibold))
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                    }
                    Text("Configurar horarios de atención")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)

                // Información
                VStack(alignment: .leading, spacing: 14) {
                    Text("Información").font(.title3.weight(.semibold))
                    HStack { Text("ID").foregroundColor(.secondary); Spacer(); Text("#\(ventanillaID)") }
                    HStack { Text("Nombre").foregroundColor(.secondary); Spacer(); Text(windowName) }
                    HStack(spacing: 10) {
                        Image(systemName: "clock").foregroundColor(.secondary)
                        Text("Actualizado").foregroundColor(.secondary)
                        Spacer()
                        Text(updatedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary).monospacedDigit()
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 6)
                .padding(.horizontal, 20)

                // Rango de fechas (opcional)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Rango de fechas (opcional)")
                        .font(.title3.weight(.semibold))
                    Toggle("Usar rango de vigencia", isOn: $usaRangoFechas)
                        .tint(.blue)
                    if usaRangoFechas {
                        VStack(spacing: 14) {
                            HStack { Text("Desde"); Spacer(); DatePicker("", selection: $fechaInicio, displayedComponents: [.date]).labelsHidden().datePickerStyle(.compact) }
                            HStack { Text("Hasta"); Spacer(); DatePicker("", selection: $fechaFin, in: fechaInicio..., displayedComponents: [.date]).labelsHidden().datePickerStyle(.compact) }
                            if fechaFin < fechaInicio {
                                Text("La fecha final debe ser posterior a la inicial.")
                                    .font(.footnote).foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 6)
                .padding(.horizontal, 20)

                // Horario semanal
                VStack(alignment: .leading, spacing: 16) {
                    Text("Horario semanal")
                        .font(.title3.weight(.semibold))
                    ForEach(days.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(days[i].name)
                                    .font(.headline)
                                Spacer()
                                Toggle("", isOn: $days[i].enabled)
                                    .labelsHidden()
                                    .tint(.blue)
                            }
                            HStack(spacing: 16) {
                                HStack { Text("Inicio"); Spacer(); DatePicker("", selection: $days[i].start, displayedComponents: .hourAndMinute).labelsHidden().datePickerStyle(.compact).disabled(!days[i].enabled).opacity(days[i].enabled ? 1 : 0.4) }
                                HStack { Text("Fin"); Spacer(); DatePicker("", selection: $days[i].end, displayedComponents: .hourAndMinute).labelsHidden().datePickerStyle(.compact).disabled(!days[i].enabled).opacity(days[i].enabled ? 1 : 0.4) }
                            }
                            if days[i].enabled && days[i].end <= days[i].start {
                                Text("La hora de fin debe ser posterior a la de inicio.")
                                    .font(.footnote).foregroundColor(.red)
                            }
                        }
                        if i != days.count - 1 { Divider() }
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 6)
                .padding(.horizontal, 20)

                // Acciones (sin backend aún)
                VStack(spacing: 12) {
                    Button(action: { updatedAt = .now }) {
                        Text(isSaving ? "Guardando…" : "Guardar cambios")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundColor(.white)
                            .background(LinearGradient(colors: [.blue, .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    Button(role: .destructive) {
                        // Restablecer por defecto
                        resetToDefault()
                    } label: {
                        Text("Restablecer por defecto")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 6)
                .padding(.horizontal, 20)

                Spacer(minLength: 12)
            }
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resetToDefault() {
        let cal = Calendar.current
        func hour(_ h: Int, _ m: Int = 0) -> Date { var c = DateComponents(); c.hour = h; c.minute = m; return cal.date(from: c) ?? Date() }
        let names = ["Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"]
        days = names.enumerated().map { idx, n in DaySchedule(name: n, enabled: idx < 5, start: hour(9), end: hour(17)) }
        usaRangoFechas = false
        fechaInicio = Date()
        fechaFin = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }
}

#Preview("iPhone 15 Pro") {
    NavigationStack { VentanillaHorariosView(ventanillaID: 2, windowName: "Ventanilla 2") }
}
