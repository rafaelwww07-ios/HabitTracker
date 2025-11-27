//
//  ProfileView.swift
//  HabitTracker
//
//  Экран профиля с прогрессом и уровнем
//

import SwiftUI

struct ProfileView: View {
    @State private var userProgress = GamificationService.shared.getUserProgress()
    let habits: [Habit]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Уровень и прогресс
                    levelSection
                    
                    // Статистика
                    statsSection
                    
                    // Бейджи
                    badgesSection
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                updateProgress()
            }
        }
    }
    
    private var levelSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: userProgress.levelProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("Уровень")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(userProgress.currentLevel)")
                        .font(.system(size: 36, weight: .bold))
                }
            }
            
            Text("\(userProgress.totalPoints) баллов")
                .font(.headline)
            
            HStack {
                Text("До следующего уровня:")
                Spacer()
                Text("\(userProgress.pointsToNextLevel) баллов")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(.headline)
            
            HStack(spacing: 16) {
                StatBox(
                    title: "Всего дней",
                    value: "\(userProgress.totalDaysTracked)",
                    icon: "calendar",
                    color: .blue
                )
                
                StatBox(
                    title: "Выполнений",
                    value: "\(userProgress.totalCompletions)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                StatBox(
                    title: "Лучший стрик",
                    value: "\(userProgress.longestStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatBox(
                    title: "Бейджей",
                    value: "\(userProgress.badgesEarned.count)",
                    icon: "rosette",
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
    
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Заработанные бейджи")
                .font(.headline)
            
            if userProgress.badgesEarned.isEmpty {
                Text("Начните отслеживать привычки, чтобы заработать бейджи!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Array(userProgress.badgesEarned), id: \.self) { badge in
                        BadgeView(badgeName: badge)
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
    }
    
    private func updateProgress() {
        userProgress = GamificationService.shared.getUserProgress()
        
        // Обновляем статистику на основе привычек
        var totalDays = 0
        var totalCompletions = 0
        var longestStreak = 0
        
        for habit in habits {
            totalCompletions += habit.completions.count
            longestStreak = max(longestStreak, habit.currentStreak())
            
            // Подсчет уникальных дней
            let uniqueDays = Set(habit.completions.map { completion in
                Calendar.current.startOfDay(for: completion.completedAt)
            })
            totalDays = max(totalDays, uniqueDays.count)
        }
        
        var updatedProgress = userProgress
        updatedProgress.updateStats(
            daysTracked: totalDays,
            completions: totalCompletions,
            streak: longestStreak
        )
        GamificationService.shared.saveUserProgress(updatedProgress)
        userProgress = updatedProgress
    }
}

struct StatBox: View {
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
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
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

struct BadgeView: View {
    let badgeName: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badgeIcon(for: badgeName))
                .font(.title)
                .foregroundColor(badgeColor(for: badgeName))
            
            Text(badgeTitle(for: badgeName))
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(badgeColor(for: badgeName).opacity(0.1))
        )
    }
    
    private func badgeIcon(for name: String) -> String {
        switch name {
        case "week_streak":
            return "flame.fill"
        case "month_streak":
            return "flame.fill"
        case "hundred_completions":
            return "100.circle.fill"
        default:
            return "star.fill"
        }
    }
    
    private func badgeColor(for name: String) -> Color {
        switch name {
        case "week_streak":
            return .orange
        case "month_streak":
            return .red
        case "hundred_completions":
            return .blue
        default:
            return .gray
        }
    }
    
    private func badgeTitle(for name: String) -> String {
        switch name {
        case "week_streak":
            return "Неделя"
        case "month_streak":
            return "Месяц"
        case "hundred_completions":
            return "100 раз"
        default:
            return "Бейдж"
        }
    }
}

#Preview {
    ProfileView(habits: [])
}

