//
//  ExportOptionsView.swift
//  HabitTracker
//
//  Export options screen
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
                        Label("Export to PDF", systemImage: "doc.fill")
                    }
                    
                    Button(action: {
                        exportToCSV()
                    }) {
                        Label("Export to CSV", systemImage: "tablecells.fill")
                    }
                    
                    Button(action: {
                        exportToJSON()
                    }) {
                        Label("Export to JSON", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text("Files")
                }
                
                Section {
                    Button(action: {
                        showCalendarExport = true
                    }) {
                        Label("Export to Calendar", systemImage: "calendar")
                    }
                    
                    Button(action: {
                        exportAsImage()
                    }) {
                        Label("Export as Image", systemImage: "photo.fill")
                    }
                } header: {
                    Text("Integrations")
                }
            }
            .navigationTitle(habit == nil ? "Export Data" : "Export Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Export", isPresented: $showAlert) {
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
            exportMessage = "PDF report created successfully"
            showAlert = true
        } else {
            exportMessage = "Error creating PDF report"
            showAlert = true
        }
    }
    
    private func exportToCSV() {
        let csv = ExportService.shared.exportToCSV(habits: habitsToExport)
        if let url = ExportService.shared.saveFile(content: csv, filename: "habits_\(Date().timeIntervalSince1970).csv") {
            ShareService.shared.share(items: [url], from: nil)
            exportMessage = "CSV file created successfully"
            showAlert = true
        }
    }
    
    private func exportToJSON() {
        do {
            let jsonData = try ExportService.shared.exportToJSON(habits: habitsToExport)
            if let url = ExportService.shared.saveData(data: jsonData, filename: "habits_\(Date().timeIntervalSince1970).json") {
                ShareService.shared.share(items: [url], from: nil)
                exportMessage = "JSON file created successfully"
                showAlert = true
            }
        } catch {
            exportMessage = "Error exporting JSON: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func exportAsImage() {
        // Create statistics image
        if let image = ShareService.shared.createStatisticsImage(habits: habitsToExport) {
            ShareService.shared.share(items: [image], from: nil)
            exportMessage = "Image created successfully"
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
                
                Text("Export to Calendar")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("All completions of \"\(habit.name)\" will be added to your iOS calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Events to create: \(habit.completions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isExporting {
                    ProgressView()
                } else {
                    Button(action: {
                        exportToCalendar()
                    }) {
                        Text("Export")
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
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Export", isPresented: $showAlert) {
                Button("OK") {
                    if exportMessage?.contains("successfully") == true {
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
            exportMessage = success ? "Export completed successfully! Events added to calendar." : (message ?? "Export error")
            showAlert = true
        }
    }
}

#Preview {
    ExportOptionsView(habit: nil, allHabits: [])
}



