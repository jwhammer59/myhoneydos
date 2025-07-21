//
//  DataManager.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/13/25.
//

import SwiftData
import Foundation

@Observable
class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Task Operations
    func createTask(title: String, description: String = "", priority: Int = 1, dueDate: Date? = nil, category: TaskCategory? = nil, tags: [TaskTag] = [], supplies: [(name: String, quantity: Int, estimatedCost: Double?, supplier: String?)] = [], in context: ModelContext) {
        let task = HoneyDoTask(
            title: title,
            taskDescription: description,
            priority: priority,
            dueDate: dueDate,
            category: category
        )
        task.tags = tags
        context.insert(task)
        
        // Add supplies if provided
        for supplyData in supplies {
            let supply = Supply(
                name: supplyData.name,
                quantity: supplyData.quantity,
                estimatedCost: supplyData.estimatedCost,
                supplier: supplyData.supplier
            )
            supply.task = task
            task.supplies.append(supply)
            context.insert(supply)
        }
        
        saveContext(context)
    }
    
    func createTaskFromTemplate(_ template: TaskTemplate, dueDate: Date? = nil, in context: ModelContext) -> HoneyDoTask {
        let task = template.createTask()
        task.dueDate = dueDate
        context.insert(task)
        
        // Insert supplies
        for supply in task.supplies {
            context.insert(supply)
        }
        
        saveContext(context)
        return task
    }
    
    func updateTask(_ task: HoneyDoTask, in context: ModelContext) {
        saveContext(context)
    }
    
    func deleteTask(_ task: HoneyDoTask, in context: ModelContext) {
        context.delete(task)
        saveContext(context)
    }
    
    func bulkCompleteTask(_ tasks: [HoneyDoTask], in context: ModelContext) {
        for task in tasks {
            task.status = TaskStatus.completed
            task.completedDate = Date()
        }
        saveContext(context)
    }
    
    func bulkDeleteTasks(_ tasks: [HoneyDoTask], in context: ModelContext) {
        for task in tasks {
            context.delete(task)
        }
        saveContext(context)
    }
    
    func duplicateTask(_ task: HoneyDoTask, in context: ModelContext) -> HoneyDoTask {
        let newTask = HoneyDoTask(
            title: "\(task.title) (Copy)",
            taskDescription: task.taskDescription,
            priority: task.priority,
            dueDate: task.dueDate,
            category: task.category
        )
        newTask.tags = task.tags
        newTask.notes = task.notes
        
        // Duplicate supplies
        for supply in task.supplies {
            let newSupply = Supply(
                name: supply.name,
                quantity: supply.quantity,
                estimatedCost: supply.estimatedCost,
                supplier: supply.supplier
            )
            newSupply.task = newTask
            newSupply.notes = supply.notes
            newTask.supplies.append(newSupply)
            context.insert(newSupply)
        }
        
        context.insert(newTask)
        saveContext(context)
        return newTask
    }
    
    // MARK: - Category Operations
    func createCategory(name: String, icon: String, color: String, in context: ModelContext) -> TaskCategory {
        let category = TaskCategory(name: name, icon: icon, color: color)
        context.insert(category)
        saveContext(context)
        return category
    }
    
    func updateCategory(_ category: TaskCategory, in context: ModelContext) {
        saveContext(context)
    }
    
    func deleteCategory(_ category: TaskCategory, in context: ModelContext) {
        // Remove category from tasks before deleting
        for task in category.tasks {
            task.category = nil
        }
        context.delete(category)
        saveContext(context)
    }
    
    func createDefaultCategories(in context: ModelContext) {
        for defaultCategory in TaskCategory.defaultCategories {
            let category = TaskCategory(
                name: defaultCategory.name,
                icon: defaultCategory.icon,
                color: defaultCategory.color
            )
            context.insert(category)
        }
        saveContext(context)
    }
    
    // MARK: - Tag Operations
    func createTag(name: String, color: String, in context: ModelContext) -> TaskTag {
        let tag = TaskTag(name: name, color: color)
        context.insert(tag)
        saveContext(context)
        return tag
    }
    
    func updateTag(_ tag: TaskTag, in context: ModelContext) {
        saveContext(context)
    }
    
    func deleteTag(_ tag: TaskTag, in context: ModelContext) {
        // Remove tag from tasks before deleting
        for task in tag.tasks {
            task.tags.removeAll { $0.id == tag.id }
        }
        context.delete(tag)
        saveContext(context)
    }
    
    // MARK: - Template Operations (UPDATED)
    func createTemplate(name: String, title: String, description: String = "", priority: Int = 3, category: TaskCategory? = nil, supplies: [SupplyTemplate] = [], tags: [TaskTag] = [], in context: ModelContext) -> TaskTemplate {
        let template = TaskTemplate(
            name: name,
            title: title,
            taskDescription: description,
            priority: priority,
            category: category
        )
        
        // Insert the template first
        context.insert(template)
        
        // Add supply templates
        for supply in supplies {
            supply.template = template
            template.supplies.append(supply)
            context.insert(supply)
        }
        
        // Add tags
        template.tags = tags
        
        // Save the context
        saveContext(context)
        return template
    }
    
    func updateTemplate(_ template: TaskTemplate, in context: ModelContext) {
        saveContext(context)
    }
    
    func deleteTemplate(_ template: TaskTemplate, in context: ModelContext) {
        context.delete(template)
        saveContext(context)
    }
    
    func createTemplateFromTask(_ task: HoneyDoTask, templateName: String, in context: ModelContext) -> TaskTemplate {
        let template = TaskTemplate(
            name: templateName,
            title: task.title,
            taskDescription: task.taskDescription,
            priority: task.priority,
            category: task.category
        )
        
        // Add supply templates
        for supply in task.supplies {
            let supplyTemplate = SupplyTemplate(
                name: supply.name,
                quantity: supply.quantity,
                estimatedCost: supply.estimatedCost,
                supplier: supply.supplier
            )
            supplyTemplate.template = template
            template.supplies.append(supplyTemplate)
            context.insert(supplyTemplate)
        }
        
        template.tags = task.tags
        context.insert(template)
        saveContext(context)
        return template
    }
    
    // MARK: - Supply Operations
    func addSupply(to task: HoneyDoTask, name: String, quantity: Int = 1, estimatedCost: Double? = nil, supplier: String? = nil, in context: ModelContext) {
        let supply = Supply(
            name: name,
            quantity: quantity,
            estimatedCost: estimatedCost,
            supplier: supplier
        )
        supply.task = task
        task.supplies.append(supply)
        context.insert(supply)
        saveContext(context)
    }
    
    func updateSupply(_ supply: Supply, name: String? = nil, quantity: Int? = nil, isObtained: Bool? = nil, estimatedCost: Double? = nil, actualCost: Double? = nil, supplier: String? = nil, notes: String? = nil, in context: ModelContext) {
        if let name = name {
            supply.name = name
        }
        if let quantity = quantity {
            supply.quantity = max(1, quantity)
        }
        if let isObtained = isObtained {
            supply.isObtained = isObtained
        }
        if let estimatedCost = estimatedCost {
            supply.estimatedCost = estimatedCost
        }
        if let actualCost = actualCost {
            supply.actualCost = actualCost
        }
        if let supplier = supplier {
            supply.supplier = supplier
        }
        if let notes = notes {
            supply.notes = notes
        }
        saveContext(context)
    }
    
    func deleteSupply(_ supply: Supply, in context: ModelContext) {
        if let task = supply.task {
            task.supplies.removeAll { $0.id == supply.id }
        }
        context.delete(supply)
        saveContext(context)
    }
    
    // MARK: - Search Operations (Using In-Memory Filtering)
    func searchTasks(query: String, in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                task.title.localizedCaseInsensitiveContains(query) ||
                task.taskDescription.localizedCaseInsensitiveContains(query) ||
                task.notes.localizedCaseInsensitiveContains(query) ||
                task.supplies.contains { $0.name.localizedCaseInsensitiveContains(query) } ||
                task.tags.contains { $0.name.localizedCaseInsensitiveContains(query) } ||
                (task.category?.name.localizedCaseInsensitiveContains(query) ?? false)
            }
        } catch {
            print("Error searching tasks: \(error)")
            return []
        }
    }
    
    // MARK: - Simplified Query Operations (In-Memory Filtering for Complex Cases)
    func fetchAllTasks() -> FetchDescriptor<HoneyDoTask> {
        return FetchDescriptor<HoneyDoTask>(sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
    }
    
    func fetchTasksByCategory(_ categoryId: UUID, in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                task.category?.id == categoryId
            }.sorted { $0.createdDate > $1.createdDate }
        } catch {
            print("Error fetching tasks by category: \(error)")
            return []
        }
    }
    
    func fetchTasksByStatus(_ status: TaskStatus, in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                task.status == status
            }.sorted { $0.createdDate > $1.createdDate }
        } catch {
            print("Error fetching tasks by status: \(error)")
            return []
        }
    }
    
    func fetchTasksByPriority(_ priority: Int, in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                task.priority == priority
            }.sorted { $0.createdDate > $1.createdDate }
        } catch {
            print("Error fetching tasks by priority: \(error)")
            return []
        }
    }
    
    func fetchOverdueTasks(in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        let currentDate = Date()
        
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate < currentDate && task.status != TaskStatus.completed
            }.sorted { task1, task2 in
                guard let date1 = task1.dueDate, let date2 = task2.dueDate else { return false }
                return date1 < date2
            }
        } catch {
            print("Error fetching overdue tasks: \(error)")
            return []
        }
    }
    
    func fetchTasksDueToday(in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        let calendar = Calendar.current
        let today = Date()
        
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDate(dueDate, inSameDayAs: today) && task.status != TaskStatus.completed
            }.sorted { task1, task2 in
                guard let date1 = task1.dueDate, let date2 = task2.dueDate else { return false }
                return date1 < date2
            }
        } catch {
            print("Error fetching tasks due today: \(error)")
            return []
        }
    }
    
    func fetchTasksDueThisWeek(in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        let calendar = Calendar.current
        let today = Date()
        
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDate(dueDate, equalTo: today, toGranularity: .weekOfYear) && task.status != TaskStatus.completed
            }.sorted { task1, task2 in
                guard let date1 = task1.dueDate, let date2 = task2.dueDate else { return false }
                return date1 < date2
            }
        } catch {
            print("Error fetching tasks due this week: \(error)")
            return []
        }
    }
    
    func fetchTasksWithNoDueDate(in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                task.dueDate == nil
            }.sorted { $0.createdDate > $1.createdDate }
        } catch {
            print("Error fetching tasks with no due date: \(error)")
            return []
        }
    }
    
    func fetchHighPriorityTasks(in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                task.priority >= 4
            }.sorted { $0.priority > $1.priority }
        } catch {
            print("Error fetching high priority tasks: \(error)")
            return []
        }
    }
    
    func fetchCompletedTasks(in context: ModelContext) -> [HoneyDoTask] {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { task in
                task.status == TaskStatus.completed
            }.sorted { task1, task2 in
                guard let date1 = task1.completedDate, let date2 = task2.completedDate else { return false }
                return date1 > date2
            }
        } catch {
            print("Error fetching completed tasks: \(error)")
            return []
        }
    }
    
    // MARK: - Filter Helper Method
    func fetchFilteredTasks(
        filter: TaskFilter? = nil,
        categoryId: UUID? = nil,
        status: TaskStatus? = nil,
        in context: ModelContext
    ) -> [HoneyDoTask] {
        
        // Handle specific filters
        if let filter = filter {
            switch filter {
            case .all:
                let descriptor = FetchDescriptor<HoneyDoTask>(sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
                return (try? context.fetch(descriptor)) ?? []
            case .today:
                return fetchTasksDueToday(in: context)
            case .overdue:
                return fetchOverdueTasks(in: context)
            case .thisWeek:
                return fetchTasksDueThisWeek(in: context)
            case .noDueDate:
                return fetchTasksWithNoDueDate(in: context)
            case .highPriority:
                return fetchHighPriorityTasks(in: context)
            case .completed:
                return fetchCompletedTasks(in: context)
            }
        }
        
        // Handle category filter
        if let categoryId = categoryId {
            return fetchTasksByCategory(categoryId, in: context)
        }
        
        // Handle status filter
        if let status = status {
            return fetchTasksByStatus(status, in: context)
        }
        
        // Default: return all tasks
        let descriptor = FetchDescriptor<HoneyDoTask>(sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Analytics Operations
    func getTaskStatistics(in context: ModelContext) -> TaskStatistics {
        let descriptor = FetchDescriptor<HoneyDoTask>()
        
        do {
            let allTasks = try context.fetch(descriptor)
            
            let total = allTasks.count
            let completed = allTasks.filter { $0.status == TaskStatus.completed }.count
            
            // Calculate overdue tasks using in-memory filtering
            let currentDate = Date()
            let overdue = allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate < currentDate && task.status != TaskStatus.completed
            }.count
            
            // Calculate tasks due today using in-memory filtering
            let calendar = Calendar.current
            let today = Date()
            let dueToday = allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDate(dueDate, inSameDayAs: today) && task.status != TaskStatus.completed
            }.count
            
            return TaskStatistics(
                total: total,
                completed: completed,
                overdue: overdue,
                dueToday: dueToday,
                completionRate: total > 0 ? Double(completed) / Double(total) : 0.0
            )
        } catch {
            print("Error fetching task statistics: \(error)")
            return TaskStatistics(total: 0, completed: 0, overdue: 0, dueToday: 0, completionRate: 0.0)
        }
    }
    
    // MARK: - Utility Methods
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - Task Statistics Model
struct TaskStatistics {
    let total: Int
    let completed: Int
    let overdue: Int
    let dueToday: Int
    let completionRate: Double
    
    var inProgress: Int {
        total - completed
    }
}
