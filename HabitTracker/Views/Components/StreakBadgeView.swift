//
//  StreakBadgeView.swift
//  HabitTracker
//
//  Бейдж стрика с анимацией
//

import SwiftUI

struct StreakBadgeView: View {
    let streak: Int
    let color: Color
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .scaleEffect(pulseScale)
                
                Image(systemName: "flame.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            .rotationEffect(.degrees(rotation))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streak)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(streak == 1 ? "день" : streak < 5 ? "дня" : "дней")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(color, lineWidth: streak > 0 ? 2 : 0)
        )
        .onAppear {
            if streak > 0 {
                startAnimations()
            }
        }
        .onChange(of: streak) { newValue in
            if newValue > 0 {
                triggerPulse()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
    
    private func triggerPulse() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            pulseScale = 1.3
            rotation = 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                pulseScale = 1.1
                rotation = 0
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakBadgeView(streak: 0, color: .blue)
        StreakBadgeView(streak: 5, color: .orange)
        StreakBadgeView(streak: 30, color: .red)
    }
    .padding()
}

