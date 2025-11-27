//
//  StreaksView.swift
//  HabitTracker
//
//  Экран всех стриков
//

import SwiftUI

struct StreaksView: View {
    let habits: [Habit]
    
    var sortedByStreak: [Habit] {
        habits.sorted { $0.currentStreak() > $1.currentStreak() }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Общая статистика стриков
                    overallStreaks
                    
                    // Список стриков по привычкам
                    habitsStreaks
                }
                .padding()
            }
            .navigationTitle("Стрики")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overallStreaks: some View {
        VStack(spacing: 16) {
            let totalStreak = habits.reduce(0) { $0 + $1.currentStreak() }
            let averageStreak = habits.isEmpty ? 0.0 : Double(totalStreak) / Double(habits.count)
            let longestStreak = habits.map { $0.currentStreak() }.max() ?? 0
            
            Text("Общие стрики")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StreakStatCard(
                    title: "Всего",
                    value: "\(totalStreak)",
                    subtitle: "дней",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StreakStatCard(
                    title: "Средний",
                    value: String(format: "%.1f", averageStreak),
                    subtitle: "дней",
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                StreakStatCard(
                    title: "Лучший",
                    value: "\(longestStreak)",
                    subtitle: "дней",
                    icon: "trophy.fill",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var habitsStreaks: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("По привычкам")
                .font(.headline)
            
            ForEach(sortedByStreak) { habit in
                StreakRowView(habit: habit)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

struct StreakStatCard: View {
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
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct StreakRowView: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: habit.iconName)
                .font(.title2)
                .foregroundColor(habit.color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(habit.color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                
                Text("\(habit.currentStreak()) дней подряд")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("\(habit.currentStreak())")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(habit.currentStreak() > 0 ? .orange : .gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    StreaksView(habits: [])
}

