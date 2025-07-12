//
//  DataManager.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftData
import Foundation

@Observable
class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Task Operations
    func createTask(title: String, description: String = "", priority: Int = 1, in context: ModelContext) {
        let task = HoneyDoTask(title: title, taskDescription: description, priority: priority)
        context.insert(task)
        saveContext(context)
    }
    
    func updateTask(_ task: HoneyDoTask, in context: ModelContext) {
        saveContext(context)
    }
    
    func deleteTask(_ task: HoneyDoTask, in context: ModelContext) {
        context.delete(task)
        saveContext(context)
    }
    
    func completeTask(_ task: HoneyDoTask, in context: ModelContext) {
        task.status = .completed
        task.completedDate = Date()
        saveContext(context)
    }
    
    func updateTaskStatus(_ task: HoneyDoTask, to status: TaskStatus, in context: ModelContext) {
        task.status = status
        if status == .completed {
            task.completedDate = Date()
        } else {
            task.completedDate = nil
        }
        saveContext(context)
    }
    
    // MARK: - Supply Operations
    func addSupply(to task: HoneyDoTask, name: String, quantity: Int = 1, in context: ModelContext) {
        let supply = Supply(name: name, quantity: quantity)
        supply.task = task
        task.supplies.append(supply)
        context.insert(supply)
        saveContext(context)
    }
    
    func updateSupply(_ supply: Supply, name: String? = nil, quantity: Int? = nil, isObtained: Bool? = nil, in context: ModelContext) {
        if let name = name {
            supply.name = name
        }
        if let quantity = quantity {
            supply.quantity = max(1, quantity)
        }
        if let isObtained = isObtained {
            supply.isObtained = isObtained
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
    
    // MARK: - Utility Methods
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Query Helpers
    func fetchTasks(sortBy: SortDescriptor<HoneyDoTask> = SortDescriptor(\.createdDate, order: .reverse)) -> FetchDescriptor<HoneyDoTask> {
        FetchDescriptor<HoneyDoTask>(sortBy: [sortBy])
    }
    
    func fetchTasksByStatus(_ status: TaskStatus) -> FetchDescriptor<HoneyDoTask> {
        let predicate = #Predicate<HoneyDoTask> { task in
            task.status == status
        }
        return FetchDescriptor<HoneyDoTask>(predicate: predicate, sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
    }
    
    func fetchTasksByPriority(_ priority: Int) -> FetchDescriptor<HoneyDoTask> {
        let predicate = #Predicate<HoneyDoTask> { task in
            task.priority == priority
        }
        return FetchDescriptor<HoneyDoTask>(predicate: predicate, sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
    }
}
