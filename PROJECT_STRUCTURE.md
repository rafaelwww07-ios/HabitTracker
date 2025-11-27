# Структура проекта HabitTracker

## 📁 Обзор структуры

```
HabitTracker/
├── HabitTracker/                    # Основная папка приложения
│   ├── Assets.xcassets/            # Ресурсы (иконки, цвета)
│   ├── ContentView.swift           # Корневой view
│   ├── HabitTrackerApp.swift       # Точка входа в приложение
│   │
│   ├── CoreData/                   # Core Data
│   │   ├── PersistenceController.swift
│   │   └── HabitTracker.xcdatamodeld/
│   │
│   ├── Models/                     # Модели данных (11 файлов)
│   │   ├── Habit.swift
│   │   ├── Habit+CoreData.swift
│   │   ├── HabitCategory.swift
│   │   ├── HabitTemplate.swift
│   │   ├── Achievement.swift
│   │   ├── Challenge.swift
│   │   ├── HabitGroup.swift
│   │   ├── HabitTrigger.swift
│   │   ├── QuantitativeHabit.swift
│   │   └── UserProgress.swift
│   │
│   ├── Repository/                 # Слой доступа к данным
│   │   ├── HabitRepository.swift
│   │   └── HabitRepository+Notes.swift
│   │
│   ├── Services/                   # Сервисы (15 файлов)
│   │   ├── NotificationManager.swift
│   │   ├── AchievementService.swift
│   │   ├── ExportService.swift
│   │   ├── PDFExportService.swift
│   │   ├── CalendarExportService.swift
│   │   ├── ShareService.swift
│   │   ├── ThemeManager.swift
│   │   ├── MotivationService.swift
│   │   ├── GamificationService.swift
│   │   ├── ChallengeService.swift
│   │   ├── HealthKitService.swift
│   │   ├── HabitGroupService.swift
│   │   ├── TriggerService.swift
│   │   ├── ReminderService.swift
│   │   └── Logger.swift
│   │
│   ├── ViewModels/                 # ViewModels (4 файла)
│   │   ├── HabitListViewModel.swift
│   │   ├── HabitListViewModel+Duplicate.swift
│   │   ├── HabitDetailViewModel.swift
│   │   └── CreateHabitViewModel.swift
│   │
│   └── Views/                      # SwiftUI Views
│       ├── Components/             # Компоненты (9 файлов)
│       │   ├── HabitCardView.swift
│       │   ├── ProgressCalendarView.swift
│       │   ├── ProgressChartView.swift
│       │   ├── StreakBadgeView.swift
│       │   ├── StreakAnimationView.swift
│       │   ├── SearchBarView.swift
│       │   ├── FilterChip.swift
│       │   ├── CompletionNotesView.swift
│       │   └── DailyMotivationWidget.swift
│       │
│       └── [Экраны]                # Основные экраны (21 файл)
│           ├── HabitListView.swift
│           ├── HabitDetailView.swift
│           ├── CreateHabitView.swift
│           ├── StatisticsView.swift
│           ├── AnalyticsView.swift
│           ├── AchievementsView.swift
│           ├── ProfileView.swift
│           ├── ChallengesView.swift
│           ├── SettingsView.swift
│           ├── BackupView.swift
│           ├── TemplatesView.swift
│           ├── ComparisonView.swift
│           ├── MotivationView.swift
│           ├── InsightsView.swift
│           ├── ExportOptionsView.swift
│           ├── HealthKitView.swift
│           ├── HeatMapCalendarView.swift
│           ├── CustomPeriodView.swift
│           ├── GroupsView.swift
│           ├── TriggersView.swift
│           ├── DashboardView.swift
│           ├── TimeOfDayStatsView.swift
│           ├── WeeklyReviewView.swift
│           ├── StreaksView.swift
│           └── OnboardingView.swift
│
└── HabitTracker.xcodeproj/         # Xcode проект
```

## 📊 Статистика

- **Всего файлов Swift**: ~70
- **Экранов**: 21
- **Компонентов**: 9
- **Сервисов**: 15
- **Моделей**: 11
- **ViewModels**: 4

## 🔑 Ключевые компоненты

### Архитектура
- **MVVM** - разделение логики и представления
- **Repository Pattern** - абстракция доступа к данным
- **Service Layer** - бизнес-логика и утилиты

### Технологии
- **SwiftUI** - современный UI фреймворк
- **Core Data** - персистентность данных
- **Combine** - реактивное программирование
- **Charts** - визуализация данных
- **UserNotifications** - уведомления
- **HealthKit** - интеграция со здоровьем
- **EventKit** - интеграция с календарем

