//
//  ExportOptionsView.swift
//  HabitTracker
//
//  Экран с опциями экспорта
//

import SwiftUI

struct ExportOptionsView: View {
    let habit: Habit?
    let allHabits: [Habit]
    @Environment(\.dismiss) var dismiss
    @State private var showPDFExport = false
    @State private var showCalendarExport = false
    @State private var showImageExport = false
    @State private var exportMessage: String?
    @State private var showAlert = false
    
    var habitsToExport: [Habit] {
        if let habit = habit {
            return [habit]
        }
        return allHabits
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        exportToPDF()
                    }) {
                        Label("Экспорт в PDF", systemImage: "doc.fill")
                    }
                    
                    Button(action: {
                        exportToCSV()
                    }) {
                        Label("Экспорт в CSV", systemImage: "tablecells.fill")
                    }
                    
                    Button(action: {
                        exportToJSON()
                    }) {
                        Label("Экспорт в JSON", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text("Файлы")
                }
                
                Section {
                    Button(action: {
                        showCalendarExport = true
                    }) {
                        Label("Экспорт в календарь", systemImage: "calendar")
                    }
                    
                    Button(action: {
                        exportAsImage()
                    }) {
                        Label("Экспорт как изображение", systemImage: "photo.fill")
                    }
                } header: {
                    Text("Интеграции")
                }
            }
            .navigationTitle(habit == nil ? "Экспорт данных" : "Экспорт привычки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .alert("Экспорт", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                if let message = exportMessage {
                    Text(message)
                }
            }
            .sheet(isPresented: $showCalendarExport) {
                if let habit = habit {
                    CalendarExportView(habit: habit)
                }
            }
        }
    }
    
    private func exportToPDF() {
        if let url = PDFExportService.shared.createPDFReport(habits: habitsToExport) {
            ShareService.shared.share(items: [url], from: nil)
            exportMessage = "PDF отчет создан успешно"
            showAlert = true
        } else {
            exportMessage = "Ошибка создания PDF отчета"
            showAlert = true
        }
    }
    
    private func exportToCSV() {
        let csv = ExportService.shared.exportToCSV(habits: habitsToExport)
        if let url = ExportService.shared.saveFile(content: csv, filename: "habits_\(Date().timeIntervalSince1970).csv") {
            ShareService.shared.share(items: [url], from: nil)
            exportMessage = "CSV файл создан успешно"
            showAlert = true
        }
    }
    
    private func exportToJSON() {
        do {
            let jsonData = try ExportService.shared.exportToJSON(habits: habitsToExport)
            if let url = ExportService.shared.saveData(data: jsonData, filename: "habits_\(Date().timeIntervalSince1970).json") {
                ShareService.shared.share(items: [url], from: nil)
                exportMessage = "JSON файл создан успешно"
                showAlert = true
            }
        } catch {
            exportMessage = "Ошибка экспорта JSON: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func exportAsImage() {
        // Создаем изображение статистики
        if let image = ShareService.shared.createStatisticsImage(habits: habitsToExport) {
            ShareService.shared.share(items: [image], from: nil)
            exportMessage = "Изображение создано успешно"
            showAlert = true
        }
    }
}

struct CalendarExportView: View {
    let habit: Habit
    @Environment(\.dismiss) var dismiss
    @State private var isExporting = false
    @State private var exportMessage: String?
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Экспорт в календарь")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Все выполнения привычки \"\(habit.name)\" будут добавлены в ваш календарь iOS")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Событий для создания: \(habit.completions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isExporting {
                    ProgressView()
                } else {
                    Button(action: {
                        exportToCalendar()
                    }) {
                        Text("Экспортировать")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Календарь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .alert("Экспорт", isPresented: $showAlert) {
                Button("OK") {
                    if exportMessage?.contains("успешно") == true {
                        dismiss()
                    }
                }
            } message: {
                if let message = exportMessage {
                    Text(message)
                }
            }
        }
    }
    
    private func exportToCalendar() {
        isExporting = true
        CalendarExportService.shared.exportToCalendar(habit: habit) { success, message in
            isExporting = false
            exportMessage = success ? "Экспорт завершен успешно! События добавлены в календарь." : (message ?? "Ошибка экспорта")
            showAlert = true
        }
    }
}

#Preview {
    ExportOptionsView(habit: nil, allHabits: [])
}

