//
//  ChallengesView.swift
//  HabitTracker
//
//  Экран челленджей
//

import SwiftUI

struct ChallengesView: View {
    @State private var challenges: [Challenge] = []
    @State private var templates: [ChallengeTemplate] = ChallengeTemplate.allCases
    @State private var showCreateChallenge = false
    @State private var selectedTemplate: ChallengeTemplate?
    let availableHabits: [Habit]
    
    var activeChallenges: [Challenge] {
        challenges.filter { $0.isActive && !$0.isCompleted }
    }
    
    var completedChallenges: [Challenge] {
        challenges.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Активные челленджи
                    if !activeChallenges.isEmpty {
                        activeSection
                    }
                    
                    // Шаблоны
                    templatesSection
                    
                    // Завершенные
                    if !completedChallenges.isEmpty {
                        completedSection
                    }
                }
                .padding()
            }
            .navigationTitle("Челленджи")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateChallenge = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                loadChallenges()
            }
        }
    }
    
    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Активные челленджи")
                .font(.headline)
            
            ForEach(activeChallenges) { challenge in
                ChallengeCard(challenge: challenge)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Шаблоны челленджей")
                .font(.headline)
            
            ForEach(templates) { template in
                TemplateChallengeCard(
                    template: template,
                    onStart: {
                        selectedTemplate = template
                        showCreateChallenge = true
                    }
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
    
    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Завершенные")
                .font(.headline)
            
            ForEach(completedChallenges) { challenge in
                ChallengeCard(challenge: challenge)
                    .opacity(0.7)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private func loadChallenges() {
        challenges = ChallengeService.shared.getAllChallenges()
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(challenge.name)
                    .font(.headline)
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(challenge.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Прогресс
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Прогресс")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(challenge.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * challenge.progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            HStack {
                Label("День \(challenge.currentDay) из \(challenge.duration)", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if challenge.isActive {
                    Text("Осталось: \(challenge.daysRemaining) дней")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct TemplateChallengeCard: View {
    let template: ChallengeTemplate
    let onStart: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.rawValue)
                    .font(.headline)
                
                Text(template.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(template.duration) дней")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(action: onStart) {
                Text("Начать")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
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
    ChallengesView(availableHabits: [])
}

