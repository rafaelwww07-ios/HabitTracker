//
//  CustomPeriodView.swift
//  HabitTracker
//
//  Статистика за кастомный период
//

import SwiftUI
import Charts

struct CustomPeriodView: View {
    let habit: Habit
    
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Выбор периода
                    periodSelector
                    
                    // Статистика
                    periodStats
                    
                    // График
                    periodChart
                }
                .padding()
            }
            .navigationTitle("Кастомный период")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var periodSelector: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("С")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        Text(startDate, style: .date)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("До")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        Text(endDate, style: .date)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
        .sheet(isPresented: $showingDatePicker) {
            DateRangePickerView(startDate: $startDate, endDate: $endDate)
        }
    }
    
    private var periodStats: some View {
        let stats = calculateStats()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(.headline)
            
            HStack(spacing: 16) {
                CustomPeriodStatBox(
                    title: "Выполнено",
                    value: "\(stats.completed)",
                    subtitle: "раз",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                CustomPeriodStatBox(
                    title: "Успех",
                    value: "\(Int(stats.successRate))%",
                    subtitle: "за период",
                    icon: "chart.bar.fill",
                    color: .blue
                )
            }
            
            CustomPeriodStatBox(
                title: "Средний стрик",
                value: String(format: "%.1f", stats.averageStreak),
                subtitle: "дней",
                icon: "flame.fill",
                color: .orange
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var periodChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("График выполнения")
                .font(.headline)
            
            let chartData = generateChartData()
            
            Chart {
                ForEach(chartData, id: \.date) { data in
                    BarMark(
                        x: .value("Дата", data.date, unit: .day),
                        y: .value("Выполнений", data.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private func calculateStats() -> (completed: Int, successRate: Double, averageStreak: Double) {
        let completions = habit.completions.filter { completion in
            completion.completedAt >= startDate && completion.completedAt <= endDate
        }
        
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let expected = Int(habit.goalValue) * (days / 7)
        let successRate = expected > 0 ? Double(completions.count) / Double(expected) * 100.0 : 0.0
        
        // Упрощенный расчет среднего стрика
        let averageStreak = Double(habit.currentStreak())
        
        return (completions.count, successRate, averageStreak)
    }
    
    private func generateChartData() -> [(date: Date, count: Int)] {
        var data: [(date: Date, count: Int)] = []
        let calendar = Calendar.current
        var currentDate = startDate
        
        while currentDate <= endDate {
            let count = habit.completions.filter { completion in
                calendar.isDate(completion.completedAt, inSameDayAs: currentDate)
            }.count
            
            data.append((date: currentDate, count: count))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }
        
        return data
    }
}

struct CustomPeriodStatBox: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct DateRangePickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("С", selection: $startDate, displayedComponents: .date)
                DatePicker("До", selection: $endDate, in: startDate..., displayedComponents: .date)
            }
            .navigationTitle("Выберите период")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CustomPeriodView(habit: Habit(
        name: "Пример",
        description: "",
        colorHex: "#007AFF",
        iconName: "star.fill"
    ))
}

