//
//  ProgressCalendarView.swift
//  HabitTracker
//
//  Минималистичный календарь прогресса
//

import SwiftUI

struct ProgressCalendarView: View {
    let completions: [Date]
    let habitColor: Color
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    @State private var currentMonth = Date()
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок с навигацией
            HStack {
                Button(action: {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth).capitalized)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
                .disabled(calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month))
            }
            .padding(.horizontal)
            
            // Календарь
            let days = generateDaysForMonth()
            let weekDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            
            VStack(spacing: 8) {
                // Дни недели
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Ячейки календаря
                ForEach(Array(days.chunked(into: 7).enumerated()), id: \.offset) { weekIndex, week in
                    HStack(spacing: 0) {
                        ForEach(week, id: \.id) { day in
                            DayCellView(
                                day: day.day,
                                isCompleted: day.isCompleted,
                                isToday: day.isToday,
                                isCurrentMonth: day.isCurrentMonth,
                                habitColor: habitColor
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private struct DayInfo {
        let id: UUID = UUID()
        let day: Int?
        let isCompleted: Bool
        let isToday: Bool
        let isCurrentMonth: Bool
    }
    
    private func generateDaysForMonth() -> [DayInfo] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart),
              let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        // Конвертируем воскресенье (1) в 0 для начала недели с понедельника
        let adjustedFirstWeekday = firstWeekday == 1 ? 7 : firstWeekday - 1
        
        var days: [DayInfo] = []
        let today = Date()
        
        // Пустые дни перед первым днем месяца
        for _ in 1..<adjustedFirstWeekday {
            days.append(DayInfo(day: nil, isCompleted: false, isToday: false, isCurrentMonth: false))
        }
        
        // Дни месяца
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                let isCompleted = completions.contains { completionDate in
                    calendar.isDate(completionDate, inSameDayAs: date)
                }
                let isToday = calendar.isDate(date, inSameDayAs: today)
                days.append(DayInfo(day: day, isCompleted: isCompleted, isToday: isToday, isCurrentMonth: true))
            }
        }
        
        // Заполняем до 42 дней (6 недель)
        while days.count < 42 {
            days.append(DayInfo(day: nil, isCompleted: false, isToday: false, isCurrentMonth: false))
        }
        
        return days
    }
}

private struct DayCellView: View {
    let day: Int?
    let isCompleted: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let habitColor: Color
    
    var body: some View {
        Group {
            if let day = day {
                ZStack {
                    Circle()
                        .fill(isCompleted ? habitColor : (isToday ? habitColor.opacity(0.2) : Color.clear))
                    
                    if isToday {
                        Circle()
                            .stroke(habitColor, lineWidth: 2)
                    }
                    
                    Text("\(day)")
                        .font(.system(size: 14, weight: isToday ? .bold : .regular))
                        .foregroundColor(
                            isCompleted ? .white :
                            (isToday ? habitColor : (isCurrentMonth ? .primary : .secondary))
                        )
                }
                .frame(width: 35, height: 35)
            } else {
                Color.clear
                    .frame(width: 35, height: 35)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    ProgressCalendarView(
        completions: [
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            Date()
        ],
        habitColor: .blue
    )
}




