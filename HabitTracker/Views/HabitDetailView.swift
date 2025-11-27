//
//  HabitDetailView.swift
//  HabitTracker
//
//  Экран деталей привычки с календарем, статистикой и графиком
//

import SwiftUI
import os.log

struct HabitDetailView: View {
    let habit: Habit
    
    @StateObject private var viewModel: HabitDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showStreakAnimation = false
    @State private var showExportOptions = false
    @State private var showHeatMap = false
    @State private var showCustomPeriod = false
    
    init(habit: Habit) {
        self.habit = habit
        _viewModel = StateObject(wrappedValue: HabitDetailViewModel(habit: habit))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок с информацией о привычке
                    headerSection
                    
                    // Статистика
                    statsSection
                    
                    // Календарь прогресса
                    calendarSection
                    
                    // График прогресса
                    chartSection
                    
                    // История
                    historySection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [habit.color.opacity(0.1), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(viewModel.habit.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        toggleCompletion()
                    }) {
                        HStack {
                            Image(systemName: viewModel.habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                            Text(viewModel.habit.isCompletedToday() ? "Выполнено" : "Отметить")
                        }
                        .foregroundColor(viewModel.habit.color)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showHeatMap = true
                        }) {
                            Label("Heat Map календарь", systemImage: "calendar")
                        }
                        
                        Button(action: {
                            showCustomPeriod = true
                        }) {
                            Label("Кастомный период", systemImage: "calendar.badge.clock")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showExportOptions = true
                        }) {
                            Label("Экспорт", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
            .onAppear {
                viewModel.loadData()
            }
            .sheet(isPresented: $showExportOptions) {
                ExportOptionsView(habit: viewModel.habit, allHabits: [])
            }
            .sheet(isPresented: $showHeatMap) {
                HeatMapCalendarView(habit: viewModel.habit, year: Calendar.current.component(.year, from: Date()))
            }
            .sheet(isPresented: $showCustomPeriod) {
                CustomPeriodView(habit: viewModel.habit)
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.habit.iconName)
                .font(.system(size: 50))
                .foregroundColor(viewModel.habit.color)
                .padding()
                .background(
                    Circle()
                        .fill(viewModel.habit.color.opacity(0.1))
                )
            
            if !viewModel.habit.description.isEmpty {
                Text(viewModel.habit.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCardView(
                title: "Текущий стрик",
                value: "\(viewModel.currentStreak)",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCardView(
                title: "Лучший стрик",
                value: "\(viewModel.bestStreak)",
                icon: "star.fill",
                color: .yellow
            )
            
            StatCardView(
                title: "Успех",
                value: "\(Int(viewModel.successRate))%",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
    }
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Календарь прогресса")
                .font(.headline)
            
            ProgressCalendarView(
                completions: viewModel.monthlyCompletions,
                habitColor: viewModel.habit.color
            )
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 4)
            )
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Прогресс по неделям")
                .font(.headline)
            
            if viewModel.weeklyStats.isEmpty {
                Text("Недостаточно данных")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                ProgressChartView(
                    data: viewModel.weeklyStats,
                    habitColor: viewModel.habit.color
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
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Последние выполнения")
                .font(.headline)
            
            let sortedCompletions = viewModel.habit.completions.sorted { $0.completedAt > $1.completedAt }
            let recentCompletions = Array(sortedCompletions.prefix(10))
            
                    if recentCompletions.isEmpty {
                        Text("Пока нет выполнений")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(recentCompletions, id: \.id) { completion in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(viewModel.habit.color)
                                    
                                    Text(formatDate(completion.completedAt))
                                        .font(.subheadline)
                                    
                                    Spacer()
                                }
                                
                                if let notes = completion.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 24)
                                }
                            }
                            .padding(.vertical, 4)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func toggleCompletion() {
        Task {
            do {
                try await viewModel.toggleCompletion()
            } catch {
                Logger.general.error("Ошибка переключения выполнения: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Stat Card View

struct StatCardView: View {
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
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

#Preview {
    let sampleHabit = Habit(
        name: "Утренняя зарядка",
        description: "30 минут каждый день",
        colorHex: "#FF6B6B",
        iconName: "figure.run",
        goalType: .daysPerWeek,
        goalValue: 5
    )
    
    HabitDetailView(habit: sampleHabit)
}

