//
//  AchievementsView.swift
//  HabitTracker
//
//  Achievements screen
//

import SwiftUI

struct AchievementsView: View {
    let habits: [Habit]
    @State private var unlockedAchievements: [Achievement] = []
    @State private var allAchievements: [AchievementType] = AchievementType.allCases
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Statistics
                    statsHeader
                    
                    // Achievements list
                    achievementsList
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                checkAchievements()
            }
        }
    }
    
    private var statsHeader: some View {
        VStack(spacing: 16) {
            Text("\(unlockedAchievements.count) / \(allAchievements.count)")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Achievements Unlocked")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var achievementsList: some View {
        LazyVStack(spacing: 16) {
            ForEach(allAchievements, id: \.self) { achievementType in
                AchievementRowView(
                    achievementType: achievementType,
                    isUnlocked: unlockedAchievements.contains { $0.type == achievementType }
                )
            }
        }
    }
    
    private func checkAchievements() {
        var newAchievements: [Achievement] = []
        
        for habit in habits {
            let habitAchievements = AchievementService.shared.checkAchievements(for: habit, allHabits: habits)
            newAchievements.append(contentsOf: habitAchievements)
        }
        
        let globalAchievements = AchievementService.shared.checkGlobalAchievements(
            allHabits: habits,
            existingAchievements: unlockedAchievements
        )
        newAchievements.append(contentsOf: globalAchievements)
        
        unlockedAchievements = newAchievements
    }
}

struct AchievementRowView: View {
    let achievementType: AchievementType
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievementType.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievementType.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? achievementType.color : .gray)
            }
            
            // Информация
            VStack(alignment: .leading, spacing: 4) {
                Text(achievementType.title)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(achievementType.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Статус
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: isUnlocked ? 4 : 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    AchievementsView(habits: [])
}



