//
//  TimeOfDayStatsView.swift
//  HabitTracker
//
//  Статистика по времени суток
//

import SwiftUI
import Charts

struct TimeOfDayStatsView: View {
    let habits: [Habit]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Распределение по времени
                    timeDistributionChart
                    
                    // Самые активные часы
                    mostActiveHours
                    
                    // Рекомендации
                    recommendations
                }
                .padding()
            }
            .navigationTitle("Активность по времени")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeDistributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Распределение активности")
                .font(.headline)
            
            let hourData = getHourDistribution()
            
            Chart {
                ForEach(Array(hourData.enumerated()), id: \.offset) { hour, count in
                    BarMark(
                        x: .value("Час", "\(hour):00"),
                        y: .value("Выполнений", count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
            }
            .frame(height: 250)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var mostActiveHours: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Самые активные часы")
                .font(.headline)
            
            let topHours = getTopActiveHours(limit: 5)
            
            ForEach(Array(topHours.enumerated()), id: \.offset) { index, hourData in
                HStack {
                    Text("\(index + 1).")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(width: 30)
                    
                    Text("\(hourData.hour):00 - \(hourData.hour + 1):00")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(hourData.count) выполнений")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Прогресс бар
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(
                                    width: geometry.size.width * min(Double(hourData.count) / Double(topHours.first?.count ?? 1), 1.0),
                                    height: 6
                                )
                        }
                    }
                    .frame(width: 100, height: 6)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Рекомендации")
                .font(.headline)
            
            let recommendation = generateRecommendation()
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text(recommendation)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    private func getHourDistribution() -> [Int] {
        var hourCounts = Array(repeating: 0, count: 24)
        
        for habit in habits {
            for completion in habit.completions {
                let hour = Calendar.current.component(.hour, from: completion.completedAt)
                hourCounts[hour] += 1
            }
        }
        
        return hourCounts
    }
    
    private func getTopActiveHours(limit: Int) -> [(hour: Int, count: Int)] {
        let hourData = getHourDistribution()
        return hourData.enumerated()
            .map { (hour: $0.offset, count: $0.element) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
    }
    
    private func generateRecommendation() -> String {
        let topHours = getTopActiveHours(limit: 1)
        guard let mostActive = topHours.first else {
            return "Начните отслеживать привычки в разное время дня, чтобы увидеть паттерны активности."
        }
        
        if mostActive.hour < 9 {
            return "Вы наиболее активны рано утром! Рассмотрите возможность установки утренних напоминаний для новых привычек."
        } else if mostActive.hour < 17 {
            return "Ваша активность сосредоточена в дневное время. Это отличное время для продуктивных привычек!"
        } else {
            return "Вы предпочитаете выполнять привычки вечером. Убедитесь, что у вас есть достаточно времени и энергии."
        }
    }
}

#Preview {
    TimeOfDayStatsView(habits: [])
}

