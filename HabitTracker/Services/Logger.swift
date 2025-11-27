//
//  Logger.swift
//  HabitTracker
//
//  Централизованный логгер для приложения
//

import Foundation
import os

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
    static let export = Logger(subsystem: subsystem, category: "export")
    static let general = Logger(subsystem: subsystem, category: "general")
}

