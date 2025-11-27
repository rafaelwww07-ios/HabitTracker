//
//  HabitCardView.swift
//  HabitTracker
//
//  Компонент карточки привычки с прогрессом и стриком
//

import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Иконка и название
            VStack(spacing: 8) {
                Image(systemName: habit.iconName)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(habit.color)
                    .scaleEffect(pulseScale)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)
                
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            
            // Прогресс круг
            ZStack {
                Circle()
                    .stroke(habit.color.opacity(0.2), lineWidth: 8)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(habit.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                
                if habit.isCompletedToday() {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(habit.color)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAnimating)
                } else {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(habit.color)
                }
            }
            
            // Стрик
            StreakBadgeView(streak: habit.currentStreak(), color: habit.color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: habit.color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(habit.isCompletedToday() ? habit.color : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture {
            onLongPress()
        }
        .onAppear {
            if habit.isCompletedToday() {
                pulseScale = 1.1
            }
        }
    }
    
    private var progress: CGFloat {
        if habit.goalType == .daysPerWeek {
            let percentage = habit.weeklyCompletionPercentage() / 100.0
            return min(max(percentage, 0), 1)
        } else {
            // Для consecutiveDays показываем прогресс к цели
            let streak = habit.currentStreak()
            return min(CGFloat(streak) / CGFloat(habit.goalValue), 1.0)
        }
    }
}

#Preview {
    let sampleHabit = Habit(
        name: "Утренняя зарядка",
        description: "30 минут",
        colorHex: "#FF6B6B",
        iconName: "figure.run",
        goalType: .daysPerWeek,
        goalValue: 5
    )
    
    HabitCardView(
        habit: sampleHabit,
        onTap: {},
        onLongPress: {}
    )
    .padding()
}

