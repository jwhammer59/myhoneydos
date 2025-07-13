//
//  TaskTemplate.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftData
import Foundation

// MARK: - Task Template Model
@Model
final class TaskTemplate {
    var id: UUID
    var name: String
    var title: String
    var taskDescription: String
    var priority: Int
    var category: TaskCategory?
    var supplies: [SupplyTemplate]
    var tags: [TaskTag]
    var createdDate: Date
    var useCount: Int
    
    init(name: String, title: String, taskDescription: String = "", priority: Int = 3, category: TaskCategory? = nil) {
        self.id = UUID()
        self.name = name
        self.title = title
        self.taskDescription = taskDescription
        self.priority = max(1, min(5, priority))
        self.category = category
        self.supplies = []
        self.tags = []
        self.createdDate = Date()
        self.useCount = 0
    }
    
    func createTask() -> HoneyDoTask {
        let task = HoneyDoTask(
            title: title,
            taskDescription: taskDescription,
            priority: priority,
            category: category
        )
        
        // Add supplies from template
        for supplyTemplate in supplies {
            let supply = Supply(
                name: supplyTemplate.name,
                quantity: supplyTemplate.quantity,
                estimatedCost: supplyTemplate.estimatedCost,
                supplier: supplyTemplate.supplier
            )
            supply.task = task
            task.supplies.append(supply)
        }
        
        // Add tags
        task.tags = tags
        
        useCount += 1
        return task
    }
}
