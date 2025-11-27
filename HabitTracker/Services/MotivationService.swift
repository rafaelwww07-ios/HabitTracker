//
//  MotivationService.swift
//  HabitTracker
//
//  Сервис мотивационных цитат
//

import Foundation

struct MotivationalQuote {
    let text: String
    let author: String?
    
    static let quotes: [MotivationalQuote] = [
        MotivationalQuote(text: "Успех — это сумма небольших усилий, повторяемых изо дня в день.", author: "Роберт Коллье"),
        MotivationalQuote(text: "Привычка — это вторая натура.", author: "Аристотель"),
        MotivationalQuote(text: "Не сдавайся. Обычно ключ поворачивается на последней попытке.", author: nil),
        MotivationalQuote(text: "Лучшее время для посадки дерева было 20 лет назад. Следующее лучшее время — сейчас.", author: "Китайская мудрость"),
        MotivationalQuote(text: "Постоянство — это секрет успеха.", author: nil),
        MotivationalQuote(text: "Мы то, что мы делаем постоянно. Совершенство, следовательно, не действие, а привычка.", author: "Аристотель"),
        MotivationalQuote(text: "Маленькие изменения со временем приводят к большим результатам.", author: nil),
        MotivationalQuote(text: "Не ждите идеального момента. Начните прямо сейчас.", author: nil),
        MotivationalQuote(text: "Победа принадлежит тем, кто настойчив.", author: nil),
        MotivationalQuote(text: "Путь в тысячу миль начинается с одного шага.", author: "Лао-цзы"),
        MotivationalQuote(text: "Каждый день — это новый шанс стать лучше.", author: nil),
        MotivationalQuote(text: "Привычки формируют характер, характер определяет судьбу.", author: nil),
        MotivationalQuote(text: "Успех — это не случайность. Это результат подготовки, упорного труда и извлечения уроков из неудач.", author: "Колин Пауэлл"),
        MotivationalQuote(text: "Верь в себя и все, что ты есть. Знай, что внутри тебя есть что-то большее, чем любое препятствие.", author: nil),
        MotivationalQuote(text: "Прогресс, а не совершенство.", author: nil)
    ]
}

class MotivationService {
    static let shared = MotivationService()
    
    private init() {}
    
    /// Получить случайную цитату
    func randomQuote() -> MotivationalQuote {
        MotivationalQuote.quotes.randomElement() ?? MotivationalQuote.quotes[0]
    }
    
    /// Получить цитату для дня
    func quoteOfTheDay() -> MotivationalQuote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % MotivationalQuote.quotes.count
        return MotivationalQuote.quotes[index]
    }
    
    /// Получить мотивационное сообщение на основе стрика
    func messageForStreak(_ streak: Int) -> String {
        switch streak {
        case 0:
            return "Начните свой путь к успеху сегодня!"
        case 1..<3:
            return "Отличное начало! Продолжайте в том же духе!"
        case 3..<7:
            return "Вы на правильном пути! Еще немного!"
        case 7..<14:
            return "Неделя подряд! Это впечатляет!"
        case 14..<30:
            return "Две недели! Вы формируете настоящую привычку!"
        case 30..<90:
            return "Месяц подряд! Вы молодец!"
        default:
            return "Невероятно! Вы настоящий мастер дисциплины!"
        }
    }
}

