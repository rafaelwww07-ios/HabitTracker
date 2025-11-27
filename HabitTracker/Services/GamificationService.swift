//
//  GamificationService.swift
//  HabitTracker
//
//  Сервис геймификации
//

import Foundation

class GamificationService {
    static let shared = GamificationService()
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "userProgress"
    
    private init() {}
    
    /// Получить прогресс пользователя
    func getUserProgress() -> UserProgress {
        guard let data = userDefaults.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return UserProgress()
        }
        return progress
    }
    
    /// Сохранить прогресс пользователя
    func saveUserProgress(_ progress: UserProgress) {
        if let data = try? JSONEncoder().encode(progress) {
            userDefaults.set(data, forKey: progressKey)
        }
    }
    
    /// Вычислить баллы за выполнение привычки
    func calculatePoints(for habit: Habit, completion: HabitCompletion) -> Int {
        var points = PointsReward.dailyCompletion.rawValue
        
        // Бонус за стрик
        let streak = habit.currentStreak()
        if streak > 0 {
            points += PointsReward.streakDay.rawValue
            
            if streak % 7 == 0 {
                points += PointsReward.streakWeek.rawValue
            }
            if streak % 30 == 0 {
                points += PointsReward.streakMonth.rawValue
            }
        }
        
        // Бонус за идеальную неделю
        if hasPerfectWeek(habit: habit) {
            points += PointsReward.perfectWeek.rawValue
        }
        
        return points
    }
    
    /// Обновить прогресс после выполнения привычки
    func updateProgressAfterCompletion(habit: Habit, completion: HabitCompletion) {
        var progress = getUserProgress()
        let points = calculatePoints(for: habit, completion: completion)
        progress.addPoints(points)
        progress.totalCompletions += 1
        progress.updateStats(
            daysTracked: calculateTotalDaysTracked(),
            completions: progress.totalCompletions,
            streak: habit.currentStreak()
        )
        saveUserProgress(progress)
    }
    
    /// Проверить и начислить достижения
    func checkAndAwardAchievements(habit: Habit, progress: inout UserProgress) {
        let streak = habit.currentStreak()
        
        if streak >= 7 && !progress.badgesEarned.contains("week_streak") {
            progress.badgesEarned.insert("week_streak")
            progress.addPoints(PointsReward.achievement.rawValue)
        }
        
        if streak >= 30 && !progress.badgesEarned.contains("month_streak") {
            progress.badgesEarned.insert("month_streak")
            progress.addPoints(PointsReward.achievement.rawValue)
        }
        
        if habit.completions.count >= 100 && !progress.badgesEarned.contains("hundred_completions") {
            progress.badgesEarned.insert("hundred_completions")
            progress.addPoints(PointsReward.achievement.rawValue)
        }
    }
    
    private func hasPerfectWeek(habit: Habit) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return false
        }
        
        let weekCompletions = habit.completions.filter { completion in
            completion.completedAt >= weekStart && completion.completedAt <= today
        }
        
        return weekCompletions.count >= Int(habit.goalValue)
    }
    
    private func calculateTotalDaysTracked() -> Int {
        // Упрощенная версия - можно улучшить
        return 0
    }
}
