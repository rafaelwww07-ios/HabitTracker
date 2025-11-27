//
//  CompletionNotesView.swift
//  HabitTracker
//
//  Компонент для добавления примечаний к выполнению
//

import SwiftUI

struct CompletionNotesView: View {
    let habit: Habit
    let completionDate: Date
    @State private var notes: String = ""
    @Environment(\.dismiss) var dismiss
    
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Дата: \(formatDate(completionDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 200)
                } header: {
                    Text("Примечания")
                } footer: {
                    Text("Добавьте заметки о выполнении привычки на этот день")
                }
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave(notes)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadExistingNotes()
        }
    }
    
    private func loadExistingNotes() {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: completionDate)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        if let completion = habit.completions.first(where: { completion in
            completion.completedAt >= dayStart && completion.completedAt < dayEnd
        }) {
            notes = completion.notes ?? ""
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleHabit = Habit(name: "Утренняя зарядка")
    CompletionNotesView(habit: sampleHabit, completionDate: Date(), onSave: { _ in })
}

