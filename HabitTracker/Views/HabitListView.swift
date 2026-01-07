//
//  HabitListView.swift
//  HabitTracker
//
//  Main screen with list of habits
//

import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var showDeleteAlert = false
    @State private var habitToDelete: Habit?
    @State private var searchText = ""
    @State private var filterOption: FilterOption = .all
    @State private var showStatistics = false
    @State private var showAchievements = false
    @State private var showTemplates = false
    @State private var showComparison = false
    @State private var showMotivation = false
    @State private var showInsights = false
    @State private var showChallenges = false
    @State private var showProfile = false
    @State private var showHealthKit = false
    @State private var showTimeStats = false
    @State private var showWeeklyReview = false
    @State private var showStreaks = false
    @State private var showDashboard = false
    @State private var showGroups = false
    @State private var showTriggers = false
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case completed = "Completed today"
        case incomplete = "Not completed"
        case highStreak = "High streak"
        case archived = "Archived"
    }
    
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showSettings = false
    @State private var showAnalytics = false
    @State private var selectedCategory: HabitCategory? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredHabits: [Habit] {
        var habits = viewModel.habits
        
        // Search
        if !searchText.isEmpty {
            habits = habits.filter { habit in
                habit.name.localizedCaseInsensitiveContains(searchText) ||
                habit.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filtering
        switch filterOption {
        case .all:
            habits = habits.filter { !$0.isArchived }
        case .completed:
            habits = habits.filter { $0.isCompletedToday() && !$0.isArchived }
        case .incomplete:
            habits = habits.filter { !$0.isCompletedToday() && !$0.isArchived }
        case .highStreak:
            habits = habits.filter { $0.currentStreak() >= 7 && !$0.isArchived }
        case .archived:
            habits = habits.filter { $0.isArchived }
        }
        
        // Category filter
        if let selectedCategory = selectedCategory {
            habits = habits.filter { $0.category == selectedCategory }
        }
        
        return habits
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background based on theme
                themeManager.currentTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Motivational quote
                        if !viewModel.habits.isEmpty {
                            motivationQuoteCard
                        }
                        
                        // Search and filters
                        if !viewModel.habits.isEmpty {
                            searchAndFilters
                        }
                        
                        if viewModel.isLoading && viewModel.habits.isEmpty {
                            ProgressView()
                                .padding(.top, 100)
                        } else if filteredHabits.isEmpty && !viewModel.habits.isEmpty {
                            emptyFilterStateView
                        } else if viewModel.habits.isEmpty {
                            emptyStateView
                        } else {
                            habitsGrid
                        }
                    }
                }
                .refreshable {
                    viewModel.loadHabits()
                }
            }
            .navigationTitle("My Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            showDashboard = true
                        }) {
                            Label("Dashboard", systemImage: "square.grid.2x2.fill")
                        }
                        
                        Button(action: {
                            showStatistics = true
                        }) {
                            Label("Statistics", systemImage: "chart.bar.fill")
                        }
                        
                        Button(action: {
                            showAnalytics = true
                        }) {
                            Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        
                        Button(action: {
                            showAchievements = true
                        }) {
                            Label("Achievements", systemImage: "trophy.fill")
                        }
                        
                        Button(action: {
                            showStreaks = true
                        }) {
                            Label("All Streaks", systemImage: "flame.fill")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showComparison = true
                        }) {
                            Label("Compare Periods", systemImage: "chart.bar.xaxis")
                        }
                        
                        Button(action: {
                            showMotivation = true
                        }) {
                            Label("Motivation", systemImage: "quote.bubble.fill")
                        }
                        
                        Button(action: {
                            showInsights = true
                        }) {
                            Label("Insights", systemImage: "lightbulb.fill")
                        }
                        
                        Button(action: {
                            showChallenges = true
                        }) {
                            Label("Challenges", systemImage: "flag.fill")
                        }
                        
                        Button(action: {
                            showTimeStats = true
                        }) {
                            Label("Time Activity", systemImage: "clock.fill")
                        }
                        
                        Button(action: {
                            showWeeklyReview = true
                        }) {
                            Label("Weekly Review", systemImage: "calendar.badge.clock")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showProfile = true
                        }) {
                            Label("Profile", systemImage: "person.fill")
                        }
                        
                        Button(action: {
                            showHealthKit = true
                        }) {
                            Label("HealthKit", systemImage: "heart.fill")
                        }
                        
                        Button(action: {
                            showGroups = true
                        }) {
                            Label("Habit Groups", systemImage: "folder.fill")
                        }
                        
                        Button(action: {
                            showTriggers = true
                        }) {
                            Label("Triggers", systemImage: "bolt.fill")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showTemplates = true
                        }) {
                            Label("From template", systemImage: "doc.text.fill")
                        }
                        
                        Button(action: {
                            viewModel.showCreateHabit()
                        }) {
                            Label("Create new", systemImage: "plus.circle.fill")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateHabit) {
                CreateHabitView(
                    viewModel: CreateHabitViewModel(existingHabit: viewModel.editingHabit),
                    onSave: { habit in
                        viewModel.saveHabit(habit)
                        viewModel.showingCreateHabit = false
                    },
                    onCancel: {
                        viewModel.showingCreateHabit = false
                    }
                )
            }
            .sheet(item: $viewModel.selectedHabit) { habit in
                HabitDetailView(habit: habit)
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showAnalytics) {
                AnalyticsView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showTemplates) {
                TemplatesView { template in
                    let habit = template.toHabit()
                    viewModel.saveHabit(habit)
                }
            }
            .sheet(isPresented: $showComparison) {
                ComparisonView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showMotivation) {
                MotivationView()
            }
            .sheet(isPresented: $showInsights) {
                InsightsView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showChallenges) {
                ChallengesView(availableHabits: viewModel.habits)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showHealthKit) {
                HealthKitView()
            }
            .sheet(isPresented: $showTimeStats) {
                TimeOfDayStatsView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showWeeklyReview) {
                WeeklyReviewView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showStreaks) {
                StreaksView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showDashboard) {
                DashboardView(habits: viewModel.habits)
            }
            .sheet(isPresented: $showGroups) {
                GroupsView(allHabits: viewModel.habits)
            }
            .sheet(isPresented: $showTriggers) {
                TriggersView(habits: viewModel.habits)
            }
            .alert("Delete habit?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let habit = habitToDelete {
                        viewModel.deleteHabit(habit)
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .onAppear {
                viewModel.loadHabits()
                
                // Request notification permission
                Task {
                    _ = await NotificationManager.shared.requestAuthorization()
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("Create your first habit!")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Start your journey to a better version of yourself")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.showCreateHabit()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create habit")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .padding(40)
    }
    
    private var searchAndFilters: some View {
        VStack(spacing: 12) {
            SearchBarView(text: $searchText)
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All categories",
                        isSelected: selectedCategory == nil
                    ) {
                        withAnimation {
                            selectedCategory = nil
                        }
                    }
                    
                    ForEach(HabitCategory.allCases) { category in
                        FilterChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Status filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        FilterChip(
                            title: option.rawValue,
                            isSelected: filterOption == option
                        ) {
                            withAnimation {
                                filterOption = option
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
    
    private var motivationQuoteCard: some View {
        let quote = MotivationService.shared.quoteOfTheDay()
        let totalStreak = viewModel.habits.reduce(0) { $0 + $1.currentStreak() }
        let message = MotivationService.shared.messageForStreak(totalStreak)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.purple)
                Text("Quote of the day")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(quote.text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            if !message.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text(message)
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
        .padding(.horizontal)
    }
    
    private var emptyFilterStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Nothing found")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 100)
    }
    
    private var habitsGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(filteredHabits) { habit in
                HabitCardView(
                    habit: habit,
                    onTap: {
                        // Tap - mark completion for today
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.toggleCompletion(for: habit)
                        }
                    },
                    onLongPress: {
                        // Long press - edit
                        viewModel.editHabit(habit)
                    }
                )
                .contextMenu {
                    Button(action: {
                        viewModel.showHabitDetails(habit)
                    }) {
                        Label("Details", systemImage: "info.circle")
                    }
                    
                    Button(action: {
                        viewModel.editHabit(habit)
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        viewModel.duplicateHabit(habit)
                    }) {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    
                    if habit.isArchived {
                        Button(action: {
                            viewModel.unarchiveHabit(habit)
                        }) {
                            Label("Unarchive", systemImage: "tray.and.arrow.up")
                        }
                    } else {
                        Button(action: {
                            viewModel.archiveHabit(habit)
                        }) {
                            Label("Archive", systemImage: "archivebox")
                        }
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: {
                        habitToDelete = habit
                        showDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    HabitListView()
}

