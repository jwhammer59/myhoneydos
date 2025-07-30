//
//  ContentView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var tasks: [HoneyDoTask]
    @Query private var categories: [TaskCategory]
    @Query private var templates: [TaskTemplate]
    
    @State private var showingAddTask = false
    @State private var selectedTask: HoneyDoTask?
    @State private var showingSearch = false
    @State private var showingFilters = false
    @State private var showingTemplates = false
    @State private var showingCategories = false
    @State private var showingBulkActions = false
    @State private var selectedTasks: Set<UUID> = []
    @State private var isSelectionMode = false
    
    // Filter states
    @State private var selectedCategory: TaskCategory?
    @State private var selectedFilter: TaskFilter?
    @State private var sortOption: SortOption = .dateCreated
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    private let searchManager = SearchManager.shared
    
    enum SortOption: String, CaseIterable {
        case dateCreated = "Date Created"
        case dueDate = "Due Date"
        case priority = "Priority"
        case status = "Status"
        case title = "Title"
        case category = "Category"
    }
    
    // MARK: - Modern Control Components
    struct CategoryFilterButton: View {
        let selectedCategory: TaskCategory?
        let categories: [TaskCategory]
        let onCategorySelected: (TaskCategory?) -> Void
        
        private let themeManager = ThemeManager.shared
        
        var body: some View {
            Menu {
                Button("All Categories") {
                    onCategorySelected(nil)
                }
                ForEach(categories, id: \.id) { category in
                    Button("\(category.icon) \(category.name)") {
                        onCategorySelected(category)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if let category = selectedCategory {
                        Text(category.icon)
                            .font(.subheadline)
                        Text(category.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.primaryText)
                    } else {
                        VStack {
                            HStack {
                                Image(systemName: "folder")
                                    .font(.subheadline)
                                    .foregroundColor(themeManager.secondaryText)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(themeManager.secondaryText)
                            }
                            .padding(.bottom, 4)
                            
                            Text("Category")
                                .font(.subheadline)
                                .foregroundColor(themeManager.primaryText)
                        }
                        
                    }
                    
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedCategory != nil ? themeManager.accentColor.opacity(0.15) : themeManager.tertiaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedCategory != nil ? themeManager.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                )
            }
        }
    }
    
    struct QuickFilterButton: View {
        let selectedFilter: TaskFilter?
        let onFilterSelected: (TaskFilter) -> Void
        
        private let themeManager = ThemeManager.shared
        
        var body: some View {
            Menu {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    Button("\(filter.icon) \(filter.rawValue)") {
                        onFilterSelected(filter)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if let filter = selectedFilter {
                        Text(filter.icon)
                            .font(.subheadline)
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(1)
                    } else {
                        VStack {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.subheadline)
                                    .foregroundColor(themeManager.secondaryText)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(themeManager.secondaryText)
                            }
                            .padding(.bottom, 4)
                            
                            Text("Filter")
                                .font(.subheadline)
                                .foregroundColor(themeManager.primaryText)
                        }
                        
                    }
                    
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedFilter != nil ? themeManager.accentColor.opacity(0.15) : themeManager.tertiaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedFilter != nil ? themeManager.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                )
            }
            .overlay(
                // Badge indicator for active filter
                selectedFilter != nil ?
                Circle()
                    .fill(themeManager.accentColor)
                    .frame(width: 8, height: 8)
                    .offset(x: 8, y: -8) : nil,
                alignment: .topTrailing
            )
        }
    }
    
    struct SortMenuButton: View {
        let sortOption: ContentView.SortOption
        let onSortSelected: (ContentView.SortOption) -> Void
        
        private let themeManager = ThemeManager.shared
        
        var body: some View {
            Menu {
                ForEach(ContentView.SortOption.allCases, id: \.self) { option in
                    Button(action: { onSortSelected(option) }) {
                        HStack {
                            Text(option.rawValue)
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                            .padding(.bottom, 4)
                        Text("Sort")
                            .font(.subheadline)
                            .foregroundColor(themeManager.primaryText)
                    }
                    
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.tertiaryBackground)
                )
            }
        }
    }
    
    struct ActiveFiltersRow: View {
        let selectedCategory: TaskCategory?
        let selectedFilter: TaskFilter?
        let onClearCategory: () -> Void
        let onClearFilter: () -> Void
        
        var body: some View {
            HStack(spacing: 8) {
                if let category = selectedCategory {
                    FilterChip(text: category.name, icon: category.icon, onRemove: onClearCategory)
                }
                
                if let filter = selectedFilter {
                    FilterChip(text: filter.rawValue, icon: filter.icon, onRemove: onClearFilter)
                }
            }
        }
    }
    
    struct SelectionModeToggle: View {
        @Binding var isSelectionMode: Bool
        let selectedCount: Int
        
        private let themeManager = ThemeManager.shared
        
        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSelectionMode.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isSelectionMode ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.subheadline)
                        .foregroundColor(isSelectionMode ? themeManager.accentColor : themeManager.secondaryText)
                    
                    if isSelectionMode {
                        Text(selectedCount > 0 ? "\(selectedCount) selected" : "Select tasks")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.primaryText)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    } else {
                        Text("Select")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelectionMode ? themeManager.accentColor.opacity(0.1) : themeManager.tertiaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelectionMode ? themeManager.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                )
            }
            .animation(.easeInOut(duration: 0.2), value: isSelectionMode)
            .animation(.easeInOut(duration: 0.2), value: selectedCount)
        }
    }
    
    var filteredTasks: [HoneyDoTask] {
        var result = showingSearch ? searchManager.searchResults : tasks
        
        // Apply category filter
        if let selectedCategory = selectedCategory {
            result = result.filter { $0.category?.id == selectedCategory.id }
        }
        
        // Apply quick filter
        if let selectedFilter = selectedFilter {
            result = result.filter { task in
                switch selectedFilter {
                case .all:
                    return true
                case .today:
                    guard let dueDate = task.dueDate else { return false }
                    return Calendar.current.isDateInToday(dueDate)
                case .overdue:
                    return task.isOverdue
                case .thisWeek:
                    guard let dueDate = task.dueDate else { return false }
                    return Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
                case .noDueDate:
                    return task.dueDate == nil
                case .highPriority:
                    return task.priority >= 4
                case .completed:
                    return task.status == .completed
                }
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateCreated:
            result = result.sorted { $0.createdDate > $1.createdDate }
        case .dueDate:
            result = result.sorted { task1, task2 in
                switch (task1.dueDate, task2.dueDate) {
                case (nil, nil): return task1.createdDate > task2.createdDate
                case (nil, _): return false
                case (_, nil): return true
                case (let date1?, let date2?): return date1 < date2
                }
            }
        case .priority:
            result = result.sorted { task1, task2 in
                if task1.priority != task2.priority {
                    return task1.priority > task2.priority
                }
                return task1.createdDate > task2.createdDate
            }
        case .status:
            result = result.sorted { $0.status.rawValue < $1.status.rawValue }
        case .title:
            result = result.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .category:
            result = result.sorted { task1, task2 in
                let cat1 = task1.category?.name ?? "ZZZ"
                let cat2 = task2.category?.name ?? "ZZZ"
                return cat1.localizedCaseInsensitiveCompare(cat2) == .orderedAscending
            }
        }
        
        return result
    }
    
    var taskStatistics: TaskStatistics {
        dataManager.getTaskStatistics(in: modelContext)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    if !showingSearch {
                        headerView
                    }
                    
                    // Search Bar or Filter Controls
                    if showingSearch {
                        searchView
                    } else {
                        controlsView
                    }
                    
                    // Task List
                    taskListView
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                if isSelectionMode {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isSelectionMode = false
                            selectedTasks.removeAll()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Actions") {
                            showingBulkActions = true
                        }
                        .disabled(selectedTasks.isEmpty)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
        .sheet(isPresented: $showingTemplates) {
            TemplateListView()
        }
        .sheet(isPresented: $showingCategories) {
            CategoryManagementView()
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(
                selectedCategory: $selectedCategory,
                selectedFilter: $selectedFilter,
                sortOption: $sortOption
            )
        }
        .confirmationDialog("Bulk Actions", isPresented: $showingBulkActions) {
            Button("Complete Selected") {
                bulkCompleteTask()
            }
            Button("Delete Selected", role: .destructive) {
                bulkDeleteTasks()
            }
            Button("Cancel", role: .cancel) { }
        }
        .onAppear {
            createDefaultCategoriesIfNeeded()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Animated Bee
                Text("🐝")
                    .font(.largeTitle)
                    .floating()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Honey Do's")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Sweet tasks await! 🍯")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Search Button
                    Button(action: { showingSearch = true }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(themeManager.accentColor)
                    }
                    
                    // Add Task Button
                    Menu {
                        Button(action: { showingAddTask = true }) {
                            Label("New Task", systemImage: "plus")
                        }
                        
                        Button(action: { showingTemplates = true }) {
                            Label("From Template", systemImage: "doc.on.doc")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.accentColor)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Enhanced Stats Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    StatCard(title: "Total", count: taskStatistics.total, icon: "📋", color: .blue)
                    StatCard(title: "To Do", count: taskStatistics.inProgress, icon: "🐝", color: .yellow)
                    StatCard(title: "Done", count: taskStatistics.completed, icon: "✅", color: .green)
                    
                    if taskStatistics.overdue > 0 {
                        StatCard(title: "Overdue", count: taskStatistics.overdue, icon: "⚠️", color: .red)
                    }
                    
                    if taskStatistics.dueToday > 0 {
                        StatCard(title: "Due Today", count: taskStatistics.dueToday, icon: "🎯", color: .orange)
                    }
                    
                    // Completion Rate
                    CompletionRateCard(rate: taskStatistics.completionRate)
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.secondaryBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var searchView: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Button(action: {
                    showingSearch = false
                    searchManager.clearSearch()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(themeManager.secondaryText)
                }
                
                SearchBar()
                
                Button(action: { showingFilters = true }) {
                    Image(systemName: searchManager.searchFilters.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .padding(.horizontal)
            
            // Search Suggestions or Recent Searches
            if !searchManager.searchText.isEmpty && !searchManager.suggestions.isEmpty {
                SuggestionsList()
            } else if searchManager.searchText.isEmpty && !searchManager.recentSearches.isEmpty {
                RecentSearchesList()
            }
        }
        .padding(.bottom, 16)
    }
    
    private var controlsView: some View {
        VStack(spacing: 16) {
            // Primary Controls Row
            HStack(spacing: 6) {
                // Category Filter with improved styling
                CategoryFilterButton(
                    selectedCategory: selectedCategory,
                    categories: categories,
                    onCategorySelected: { selectedCategory = $0 }
                )
                
                Spacer()
                
                // Quick Filters with badge indicator
                QuickFilterButton(
                    selectedFilter: selectedFilter,
                    onFilterSelected: { selectedFilter = selectedFilter == $0 ? nil : $0 }
                )
                
                Spacer()
                
                // Sort Menu with cleaner design
                SortMenuButton(
                    sortOption: sortOption,
                    onSortSelected: { sortOption = $0 }
                )
            }
            
            // Secondary Controls Row (when needed)
            if selectedCategory != nil || selectedFilter != nil || isSelectionMode {
                HStack(spacing: 12) {
                    // Active Filters Display
                    if selectedCategory != nil || selectedFilter != nil {
                        ActiveFiltersRow(
                            selectedCategory: selectedCategory,
                            selectedFilter: selectedFilter,
                            onClearCategory: { selectedCategory = nil },
                            onClearFilter: { selectedFilter = nil }
                        )
                    }
                    
                    Spacer()
                    
                    // Selection Mode Toggle with descriptive text
                    SelectionModeToggle(
                        isSelectionMode: $isSelectionMode,
                        selectedCount: selectedTasks.count
                    )
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                // Selection Mode Toggle (always visible but compact when no filters)
                HStack {
                    Spacer()
                    
                    SelectionModeToggle(
                        isSelectionMode: $isSelectionMode,
                        selectedCount: selectedTasks.count
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .padding(.top, 12)
        .animation(.easeInOut(duration: 0.3), value: selectedCategory != nil || selectedFilter != nil || isSelectionMode)
    }
    
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredTasks.isEmpty {
                    EmptyStateView(
                        icon: showingSearch ? "magnifyingglass" : "🐝",
                        title: showingSearch ? "No tasks found" : "No tasks yet",
                        subtitle: showingSearch ? "Try adjusting your search or filters" : "Create your first honey do!"
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(filteredTasks) { task in
                        TaskCardView(
                            task: task,
                            isSelected: selectedTasks.contains(task.id),
                            isSelectionMode: isSelectionMode,
                            onTap: {
                                if isSelectionMode {
                                    toggleTaskSelection(task)
                                } else {
                                    selectedTask = task
                                }
                            },
                            onSelect: { toggleTaskSelection(task) }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
        .animation(AnimationManager.listItemSlide, value: filteredTasks.count)
    }
    
    // MARK: - Helper Functions
    private func toggleTaskSelection(_ task: HoneyDoTask) {
        if selectedTasks.contains(task.id) {
            selectedTasks.remove(task.id)
        } else {
            selectedTasks.insert(task.id)
        }
    }
    
    private func bulkCompleteTask() {
        let tasksToComplete = filteredTasks.filter { selectedTasks.contains($0.id) }
        dataManager.bulkCompleteTask(tasksToComplete, in: modelContext)
        selectedTasks.removeAll()
        isSelectionMode = false
    }
    
    private func bulkDeleteTasks() {
        let tasksToDelete = filteredTasks.filter { selectedTasks.contains($0.id) }
        dataManager.bulkDeleteTasks(tasksToDelete, in: modelContext)
        selectedTasks.removeAll()
        isSelectionMode = false
    }
    
    private func createDefaultCategoriesIfNeeded() {
        if categories.isEmpty {
            dataManager.createDefaultCategories(in: modelContext)
        }
    }
}

// MARK: - Supporting Views
struct SearchBar: View {
    @State private var searchManager = SearchManager.shared
    @Environment(\.modelContext) private var modelContext
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.secondaryText)
            
            TextField("Search tasks, categories, tags...", text: $searchManager.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: searchManager.searchText) {
                    searchManager.performSearch(in: modelContext)
                }
                .onSubmit {
                    if !searchManager.searchText.isEmpty {
                        searchManager.addToRecentSearches(searchManager.searchText)
                    }
                }
            
            if !searchManager.searchText.isEmpty {
                Button(action: { searchManager.clearSearch() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.secondaryText)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(themeManager.tertiaryBackground)
        .cornerRadius(10)
    }
}

struct SuggestionsList: View {
    @State private var searchManager = SearchManager.shared
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(searchManager.suggestions) { suggestion in
                    Button(action: {
                        searchManager.searchText = suggestion.text
                        searchManager.addToRecentSearches(suggestion.text)
                    }) {
                        HStack(spacing: 6) {
                            Text(suggestion.icon)
                                .font(.caption)
                            Text(suggestion.text)
                                .font(.caption)
                                .foregroundColor(themeManager.primaryText)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.accentColor.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct RecentSearchesList: View {
    @State private var searchManager = SearchManager.shared
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Searches")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                
                Spacer()
                
                Button("Clear") {
                    searchManager.clearRecentSearches()
                }
                .font(.caption)
                .foregroundColor(themeManager.accentColor)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(searchManager.recentSearches, id: \.self) { search in
                        Button(action: {
                            searchManager.searchText = search
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                Text(search)
                                    .font(.caption)
                                    .foregroundColor(themeManager.primaryText)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(themeManager.tertiaryBackground)
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct FilterChip: View {
    let text: String
    let icon: String
    let onRemove: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .foregroundColor(themeManager.primaryText)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(themeManager.secondaryText)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(themeManager.accentColor.opacity(0.2))
        .cornerRadius(6)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 60))
                .opacity(0.5)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.primaryText)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title2)
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(minWidth: 70)
        .padding(.vertical, 12)
        .background(themeManager.tertiaryBackground)
        .cornerRadius(12)
    }
}

struct CompletionRateCard: View {
    let rate: Double
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 4) {
            Text("📊")
                .font(.title2)
            Text("\(Int(rate * 100))%")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.accentColor)
            Text("Complete")
                .font(.caption)
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(minWidth: 80)
        .padding(.vertical, 12)
        .background(themeManager.tertiaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: HoneyDoTask.self, inMemory: true)
    }
}
