//
//  DailyMotivationWidget.swift
//  HabitTracker
//
//  Виджет ежедневной мотивации
//

import SwiftUI

struct DailyMotivationWidget: View {
    let quote: MotivationalQuote
    let streakMessage: String
    @State private var animate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .scaleEffect(animate ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
                
                Text("Вдохновение дня")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(quote.text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
            
            if !streakMessage.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text(streakMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    DailyMotivationWidget(
        quote: MotivationalQuote(text: "Успех — это сумма небольших усилий, повторяемых изо дня в день.", author: nil),
        streakMessage: "Отличное начало! Продолжайте в том же духе!"
    )
    .padding()
}

