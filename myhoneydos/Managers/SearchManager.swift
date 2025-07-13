//
//  SearchManager.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftUI
import SwiftData
import Foundation

@Observable
class SearchManager {
    static let shared = SearchManager()
    
    // Search state
    var searchText = ""
    var isSearching = false
    var searchResults: [HoneyDoTask] = []
    var recentSearches: [String] = []
    var searchFilters = SearchFilters()
    
    // Search suggestions
    var suggestions: [SearchSuggestion] = []
    
    private let maxRecentSearches = 10
    private var searchTask: Task<Void, Never>?
    
    private init() {
        loadRecentSearches()
    }
    
    // MARK: - Search Operations
    func performSearch(in context: ModelContext) {
        // Cancel previous search
        searchTask?.cancel()
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            suggestions = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        searchTask = Task { @MainActor in
            do {
                // Add delay for debouncing
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms
                
                if Task.isCancelled { return }
                
                // Perform search synchronously on main actor
                let results = performAdvancedSearch(in: context)
                
                if !Task.isCancelled {
                    searchResults = results
                    updateSuggestions(in: context)
                    isSearching = false
                }
            } catch {
                if !Task.isCancelled {
                    searchResults = []
                    suggestions = []
                    isSearching = false
                }
            }
        }
    }
    
    @MainActor
    private func performAdvancedSearch(in context: ModelContext) -> [HoneyDoTask] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let descriptor = FetchDescriptor<HoneyDoTask>()
        
        do {
            let allTasks = try context.fetch(descriptor)
            
            return allTasks.filter { task in
                // Apply search filters
                if !searchFilters.matchesFilters(task) {
                    return false
                }
                
                // Text search
                return matchesSearchQuery(task: task, query: query)
            }.sorted { task1, task2 in
                // Sort by relevance score
                let score1 = calculateRelevanceScore(task: task1, query: query)
                let score2 = calculateRelevanceScore(task: task2, query: query)
                return score1 > score2
            }
        } catch {
            print("Error performing search: \(error)")
            return []
        }
    }
    
    private func matchesSearchQuery(task: HoneyDoTask, query: String) -> Bool {
        let searchableText = [
            task.title,
            task.taskDescription,
            task.notes,
            task.category?.name ?? "",
            task.supplies.map { $0.name }.joined(separator: " "),
            task.tags.map { $0.name }.joined(separator: " ")
        ].joined(separator: " ").lowercased()
        
        // Split query into words for better matching
        let queryWords = query.components(separatedBy: .whitespaces)
        
        // Check if all query words are found
        return queryWords.allSatisfy { word in
            searchableText.contains(word)
        }
    }
    
    private func calculateRelevanceScore(task: HoneyDoTask, query: String) -> Int {
        var score = 0
        let queryLower = query.lowercased()
        
        // Title matches get highest score
        if task.title.lowercased().contains(queryLower) {
            score += 100
            if task.title.lowercased().hasPrefix(queryLower) {
                score += 50 // Bonus for prefix match
            }
        }
        
        // Description matches
        if task.taskDescription.lowercased().contains(queryLower) {
            score += 50
        }
        
        // Category matches
        if let category = task.category, category.name.lowercased().contains(queryLower) {
            score += 30
        }
        
        // Tag matches
        for tag in task.tags {
            if tag.name.lowercased().contains(queryLower) {
                score += 25
            }
        }
        
        // Supply matches
        for supply in task.supplies {
            if supply.name.lowercased().contains(queryLower) {
                score += 20
            }
        }
        
        // Priority bonus
        score += task.priority * 5
        
        // Due date urgency bonus
        if task.isUrgent {
            score += 15
        }
        
        if task.isOverdue {
            score += 10
        }
        
        return score
    }
    
    // MARK: - Search Suggestions
    @MainActor
    private func updateSuggestions(in context: ModelContext) {
        let query = searchText.lowercased()
        var newSuggestions: [SearchSuggestion] = []
        
        // Get all data for suggestions
        let categoryDescriptor = FetchDescriptor<TaskCategory>()
        let tagDescriptor = FetchDescriptor<TaskTag>()
        let taskDescriptor = FetchDescriptor<HoneyDoTask>()
        
        do {
            let categories = try context.fetch(categoryDescriptor)
            let tags = try context.fetch(tagDescriptor)
            let tasks = try context.fetch(taskDescriptor)
            
            // Category suggestions
            for category in categories {
                if category.name.lowercased().contains(query) {
                    newSuggestions.append(SearchSuggestion(
                        type: .category,
                        text: category.name,
                        icon: category.icon,
                        subtitle: "Category"
                    ))
                }
            }
            
            // Tag suggestions
            for tag in tags {
                if tag.name.lowercased().contains(query) {
                    newSuggestions.append(SearchSuggestion(
                        type: .tag,
                        text: tag.name,
                        icon: "🏷️",
                        subtitle: "Tag"
                    ))
                }
            }
            
            // Task title suggestions
            for task in tasks.prefix(5) {
                if task.title.lowercased().contains(query) {
                    newSuggestions.append(SearchSuggestion(
                        type: .task,
                        text: task.title,
                        icon: task.status.icon,
                        subtitle: "Task"
                    ))
                }
            }
            
            // Common search terms
            let commonTerms = ["high priority", "overdue", "today", "completed", "in progress"]
            for term in commonTerms {
                if term.contains(query) && query.count >= 2 {
                    newSuggestions.append(SearchSuggestion(
                        type: .filter,
                        text: term,
                        icon: "🔍",
                        subtitle: "Filter"
                    ))
                }
            }
            
            suggestions = Array(newSuggestions.prefix(8))
        } catch {
            print("Error updating suggestions: \(error)")
            suggestions = []
        }
    }
    
    // MARK: - Recent Searches
    func addToRecentSearches(_ searchTerm: String) {
        let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Remove if already exists
        recentSearches.removeAll { $0 == trimmed }
        
        // Add to beginning
        recentSearches.insert(trimmed, at: 0)
        
        // Limit to max count
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "HoneyDo_RecentSearches")
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "HoneyDo_RecentSearches") ?? []
    }
    
    // MARK: - Search Filters
    func applyQuickFilter(_ filter: TaskFilter) {
        searchFilters.quickFilter = filter
        searchText = filter.rawValue
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        suggestions = []
        isSearching = false
        searchTask?.cancel()
    }
    
    func resetFilters() {
        searchFilters = SearchFilters()
    }
}

// MARK: - Search Models
struct SearchSuggestion: Identifiable, Sendable {
    let id = UUID()
    let type: SuggestionType
    let text: String
    let icon: String
    let subtitle: String
    
    enum SuggestionType: Sendable {
        case category, tag, task, filter
    }
}

@Observable
class SearchFilters {
    var quickFilter: TaskFilter?
    var selectedCategories: Set<UUID> = []
    var selectedTags: Set<UUID> = []
    var selectedStatuses: Set<TaskStatus> = []
    var priorityRange: ClosedRange<Int> = 1...5
    var dateFilter: DateFilter = .any
    var dueDateRange: DateRange?
    
    func matchesFilters(_ task: HoneyDoTask) -> Bool {
        // Quick filter check
        if let quickFilter = quickFilter {
            switch quickFilter {
            case .all:
                break
            case .today:
                guard let dueDate = task.dueDate else { return false }
                if !Calendar.current.isDateInToday(dueDate) { return false }
            case .overdue:
                if !task.isOverdue { return false }
            case .thisWeek:
                guard let dueDate = task.dueDate else { return false }
                if !Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear) { return false }
            case .noDueDate:
                if task.dueDate != nil { return false }
            case .highPriority:
                if task.priority < 4 { return false }
            case .completed:
                if task.status != .completed { return false }
            }
        }
        
        // Category filter
        if !selectedCategories.isEmpty {
            guard let categoryId = task.category?.id,
                  selectedCategories.contains(categoryId) else { return false }
        }
        
        // Tag filter
        if !selectedTags.isEmpty {
            let taskTagIds = Set(task.tags.map { $0.id })
            if taskTagIds.isDisjoint(with: selectedTags) { return false }
        }
        
        // Status filter
        if !selectedStatuses.isEmpty {
            if !selectedStatuses.contains(task.status) { return false }
        }
        
        // Priority filter
        if !priorityRange.contains(task.priority) { return false }
        
        // Date filter
        switch dateFilter {
        case .any:
            break
        case .today:
            guard let dueDate = task.dueDate else { return false }
            if !Calendar.current.isDateInToday(dueDate) { return false }
        case .tomorrow:
            guard let dueDate = task.dueDate else { return false }
            if !Calendar.current.isDateInTomorrow(dueDate) { return false }
        case .thisWeek:
            guard let dueDate = task.dueDate else { return false }
            if !Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear) { return false }
        case .nextWeek:
            guard let dueDate = task.dueDate else { return false }
            let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
            if !Calendar.current.isDate(dueDate, equalTo: nextWeek, toGranularity: .weekOfYear) { return false }
        case .overdue:
            if !task.isOverdue { return false }
        case .noDueDate:
            if task.dueDate != nil { return false }
        case .custom:
            if let range = dueDateRange {
                guard let dueDate = task.dueDate else { return false }
                if !(range.startDate...range.endDate).contains(dueDate) { return false }
            }
        }
        
        return true
    }
    
    var hasActiveFilters: Bool {
        return quickFilter != nil ||
        !selectedCategories.isEmpty ||
        !selectedTags.isEmpty ||
        !selectedStatuses.isEmpty ||
        priorityRange != 1...5 ||
        dateFilter != .any
    }
}

enum DateFilter: String, CaseIterable, Sendable {
    case any = "Any Date"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case nextWeek = "Next Week"
    case overdue = "Overdue"
    case noDueDate = "No Due Date"
    case custom = "Custom Range"
    
    var icon: String {
        switch self {
        case .any: return "📅"
        case .today: return "🎯"
        case .tomorrow: return "➡️"
        case .thisWeek: return "🗓️"
        case .nextWeek: return "⏭️"
        case .overdue: return "⚠️"
        case .noDueDate: return "∞"
        case .custom: return "📊"
        }
    }
}

struct DateRange: Sendable {
    let startDate: Date
    let endDate: Date
}

// MARK: - Calendar Extensions
extension Calendar {
    func isDateInTomorrow(_ date: Date) -> Bool {
        guard let tomorrow = self.date(byAdding: .day, value: 1, to: Date()) else { return false }
        return isDate(date, inSameDayAs: tomorrow)
    }
}
