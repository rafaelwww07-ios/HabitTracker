//
//  HeatMapCalendarView.swift
//  HabitTracker
//
//  Heat Map календарь активности
//

import SwiftUI

struct HeatMapCalendarView: View {
    let habit: Habit
    let year: Int
    
    @State private var selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Годовая активность \(year)")
                .font(.headline)
            
            let weeks = generateWeeks()
            
            // Легенда
            HStack {
                Text("Меньше")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 3) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(intensityColor(for: Double(index) / 4.0))
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text("Больше")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Календарь
            HStack(alignment: .top, spacing: 2) {
                // Дни недели
                VStack(spacing: 2) {
                    Text("")
                        .frame(width: 20, height: 12)
                    ForEach(["Пн", "Ср", "Пт"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(width: 20, height: 12)
                    }
                }
                
                // Недели года
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 2) {
                        ForEach(weeks, id: \.weekNumber) { week in
                            VStack(spacing: 2) {
                                Text("\(week.weekNumber)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .frame(width: 12, height: 12)
                                
                                ForEach(Array(week.days.enumerated()), id: \.offset) { index, dayData in
                                    if let dayData = dayData {
                                        Button(action: {
                                            selectedDate = dayData.date
                                        }) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(intensityColor(for: dayData.intensity))
                                                .frame(width: 12, height: 12)
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.clear)
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Информация о выбранном дне
            if let selectedDate = selectedDate {
                let completions = habit.completions.filter { completion in
                    Calendar.current.isDate(completion.completedAt, inSameDayAs: selectedDate)
                }
                
                if !completions.isEmpty {
                    HStack {
                        Text(selectedDate, style: .date)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("Выполнено \(completions.count) раз")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private func intensityColor(for intensity: Double) -> Color {
        switch intensity {
        case 0:
            return Color.gray.opacity(0.2)
        case 0...0.25:
            return Color.blue.opacity(0.4)
        case 0.25...0.5:
            return Color.blue.opacity(0.6)
        case 0.5...0.75:
            return Color.blue.opacity(0.8)
        default:
            return Color.blue
        }
    }
    
    private func generateWeeks() -> [WeekData] {
        let calendar = Calendar.current
        var weeks: [WeekData] = []
        
        guard let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let yearEnd = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else {
            return weeks
        }
        
        var currentDate = yearStart
        var currentWeek: [DayData?] = []
        var weekNumber = 1
        
        // Начинаем с понедельника
        let weekday = calendar.component(.weekday, from: currentDate)
        let daysToMonday = (weekday + 5) % 7
        
        // Заполняем пустые дни до понедельника
        for _ in 0..<daysToMonday {
            currentWeek.append(nil)
        }
        
        while currentDate <= yearEnd {
            let completions = habit.completions.filter { completion in
                calendar.isDate(completion.completedAt, inSameDayAs: currentDate)
            }
            
            let intensity = min(Double(completions.count) / 3.0, 1.0) // Максимум 3 выполнения = 100%
            
            currentWeek.append(DayData(date: currentDate, intensity: intensity))
            
            if calendar.component(.weekday, from: currentDate) == 0 { // Воскресенье
                weeks.append(WeekData(weekNumber: weekNumber, days: currentWeek))
                currentWeek = []
                weekNumber += 1
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Добавляем последнюю неделю
        if !currentWeek.isEmpty {
            // Заполняем до конца недели
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(WeekData(weekNumber: weekNumber, days: currentWeek))
        }
        
        return weeks
    }
}

struct DayData: Hashable {
    let date: Date
    let intensity: Double
}

struct WeekData {
    let weekNumber: Int
    let days: [DayData?]
}

#Preview {
    HeatMapCalendarView(
        habit: Habit(
            name: "Пример",
            description: "",
            colorHex: "#007AFF",
            iconName: "star.fill"
        ),
        year: 2024
    )
}

