#!/bin/bash

# Скрипт для публикации проекта HabitTracker на GitHub

set -e

echo "🚀 Публикация HabitTracker на GitHub..."
echo ""

# Проверка git
if ! command -v git &> /dev/null; then
    echo "❌ Git не установлен"
    exit 1
fi

# Проверка статуса
echo "📋 Проверка статуса репозитория..."
if [ -d ".git" ]; then
    echo "✅ Git репозиторий найден"
else
    echo "ℹ️  Инициализация git репозитория..."
    git init
fi

# Добавление файлов
echo ""
echo "📦 Добавление файлов..."
git add .

# Проверка изменений
if git diff --cached --quiet; then
    echo "⚠️  Нет изменений для коммита"
else
    echo "✅ Файлы добавлены"
fi

# Создание коммита (если есть изменения)
if ! git diff --cached --quiet; then
    echo ""
    echo "💾 Создание коммита..."
    git commit -m "Initial commit: HabitTracker iOS app

Full-featured habit tracking application with:
- MVVM + Repository architecture
- 21 screens with SwiftUI
- Gamification system (points, levels, achievements)
- Advanced analytics and statistics
- Heat Map calendar visualization
- HealthKit and Calendar integration
- PDF/CSV/JSON export capabilities
- Challenges and triggers system
- 60+ features total"
    echo "✅ Коммит создан"
fi

# Создание тега
echo ""
echo "🏷️  Создание тега v1.0.0..."
if git rev-parse v1.0.0 >/dev/null 2>&1; then
    echo "⚠️  Тег v1.0.0 уже существует"
else
    git tag -a v1.0.0 -m "Release 1.0.0

Full-featured habit tracking app with gamification, analytics, and 60+ features.
Built with SwiftUI, Core Data, and following MVVM + Repository architecture."
    echo "✅ Тег v1.0.0 создан"
fi

echo ""
echo "✅ Локальная подготовка завершена!"
echo ""
echo "📤 Следующие шаги:"
echo ""
echo "1. Создайте репозиторий на GitHub:"
echo "   https://github.com/new"
echo ""
echo "2. Название: HabitTracker"
echo "   Описание: 📱 Мотивационное iOS приложение для отслеживания привычек с геймификацией, расширенной аналитикой и множеством функций. Built with SwiftUI."
echo "   Теги: swift, swiftui, ios, habit-tracker, mvvm, core-data, gamification, analytics"
echo ""
echo "3. Добавьте remote и отправьте код:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/HabitTracker.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo "   git push origin v1.0.0"
echo ""
echo "📝 Подробные инструкции в файле PUBLISH.md"

