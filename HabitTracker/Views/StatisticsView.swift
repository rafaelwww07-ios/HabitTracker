//
//  StatisticsView.swift
//  HabitTracker
//
//  Overall statistics screen
//

import SwiftUI
import Charts

struct StatisticsView: View {
    let habits: [Habit]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overall statistics
                    overallStats
                    
                    // Habits progress
                    habitsProgress
                    
                    // Top habits
                    topHabits
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overallStats: some View {
        VStack(spacing: 16) {
            Text("Overall Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Habits",
                    value: "\(habits.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Completions",
                    value: "\(totalCompletions)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Average Streak",
                    value: String(format: "%.0f", averageStreak),
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Success Rate",
                    value: String(format: "%.0f%%", overallSuccessRate),
                    icon: "chart.bar.fill",
                    color: .purple
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
    
    private var habitsProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Прогресс по привычкам")
                .font(.headline)
            
            ForEach(habits) { habit in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: habit.iconName)
                            .foregroundColor(habit.color)
                        
                        Text(habit.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(habit.overallCompletionPercentage()))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(habit.color.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(habit.color)
                                .frame(
                                    width: geometry.size.width * min(habit.overallCompletionPercentage() / 100.0, 1.0),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
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
    
    private var topHabits: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Топ привычек")
                .font(.headline)
            
            let sortedHabits = habits.sorted { $0.currentStreak() > $1.currentStreak() }
            
            ForEach(Array(sortedHabits.prefix(5).enumerated()), id: \.element.id) { index, habit in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(habit.color)
                        )
                    
                    Image(systemName: habit.iconName)
                        .foregroundColor(habit.color)
                    
                    Text(habit.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("\(habit.currentStreak())")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
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
    
    // MARK: - Computed Properties
    
    private var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.completions.count }
    }
    
    private var averageStreak: Double {
        guard !habits.isEmpty else { return 0 }
        let totalStreak = habits.reduce(0) { $0 + $1.currentStreak() }
        return Double(totalStreak) / Double(habits.count)
    }
    
    private var overallSuccessRate: Double {
        guard !habits.isEmpty else { return 0 }
        let totalRate = habits.reduce(0.0) { $0 + $1.overallCompletionPercentage() }
        return totalRate / Double(habits.count)
    }
}

struct StatCard: View {
    let title: String
    let value: String
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
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    StatisticsView(habits: [])
}



