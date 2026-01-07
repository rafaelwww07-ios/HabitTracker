//
//  MotivationService.swift
//  HabitTracker
//
//  Motivational quotes service
//

import Foundation

struct MotivationalQuote {
    let text: String
    let author: String?
    
    static let quotes: [MotivationalQuote] = [
        MotivationalQuote(text: "Success is the sum of small efforts, repeated day in and day out.", author: "Robert Collier"),
        MotivationalQuote(text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Aristotle"),
        MotivationalQuote(text: "Don't give up. Usually the key turns on the last try.", author: nil),
        MotivationalQuote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
        MotivationalQuote(text: "Consistency is the secret to success.", author: nil),
        MotivationalQuote(text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Aristotle"),
        MotivationalQuote(text: "Small changes over time lead to big results.", author: nil),
        MotivationalQuote(text: "Don't wait for the perfect moment. Start right now.", author: nil),
        MotivationalQuote(text: "Victory belongs to those who persevere.", author: nil),
        MotivationalQuote(text: "A journey of a thousand miles begins with a single step.", author: "Lao Tzu"),
        MotivationalQuote(text: "Every day is a new chance to become better.", author: nil),
        MotivationalQuote(text: "Habits form character, character determines destiny.", author: nil),
        MotivationalQuote(text: "Success is no accident. It is hard work, perseverance, learning, studying, sacrifice and most of all, love of what you are doing.", author: "Pele"),
        MotivationalQuote(text: "Believe in yourself and all that you are. Know that there is something inside you that is greater than any obstacle.", author: nil),
        MotivationalQuote(text: "Progress, not perfection.", author: nil)
    ]
}

class MotivationService {
    static let shared = MotivationService()
    
    private init() {}
    
    /// Get random quote
    func randomQuote() -> MotivationalQuote {
        MotivationalQuote.quotes.randomElement() ?? MotivationalQuote.quotes[0]
    }
    
    /// Get quote of the day
    func quoteOfTheDay() -> MotivationalQuote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % MotivationalQuote.quotes.count
        return MotivationalQuote.quotes[index]
    }
    
    /// Get motivational message based on streak
    func messageForStreak(_ streak: Int) -> String {
        switch streak {
        case 0:
            return "Start your journey to success today!"
        case 1..<3:
            return "Great start! Keep it up!"
        case 3..<7:
            return "You're on the right track! Just a bit more!"
        case 7..<14:
            return "A week straight! That's impressive!"
        case 14..<30:
            return "Two weeks! You're building a real habit!"
        case 30..<90:
            return "A month straight! You're doing great!"
        default:
            return "Incredible! You're a true master of discipline!"
        }
    }
}



