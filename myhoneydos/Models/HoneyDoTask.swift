//
//  HoneyDoTask.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftData
import Foundation

// MARK: - Enhanced Task Model
@Model
final class HoneyDoTask {
    var id: UUID
    var title: String
    var taskDescription: String
    var priority: Int // 1-5 heart rating
    var status: TaskStatus
    var createdDate: Date
    var completedDate: Date?
    var dueDate: Date?
    var isOverdue: Bool {
        guard let dueDate = dueDate, status != .completed else { return false }
        return Date() > dueDate
    }
    var supplies: [Supply]
    var category: TaskCategory?
    var tags: [TaskTag]
    var isTemplate: Bool
    var templateName: String?
    var reminderEnabled: Bool
    var notes: String
    
    init(title: String, taskDescription: String = "", priority: Int = 1, status: TaskStatus = .toDo, dueDate: Date? = nil, category: TaskCategory? = nil, isTemplate: Bool = false, templateName: String? = nil) {
        self.id = UUID()
        self.title = title
        self.taskDescription = taskDescription
        self.priority = max(1, min(5, priority))
        self.status = status
        self.createdDate = Date()
        self.completedDate = nil
        self.dueDate = dueDate
        self.supplies = []
        self.category = category
        self.tags = []
        self.isTemplate = isTemplate
        self.templateName = templateName
        self.reminderEnabled = false
        self.notes = ""
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var priorityHearts: String {
        String(repeating: "❤️", count: priority) + String(repeating: "🤍", count: 5 - priority)
    }
    
    var dueDateFormatted: String? {
        guard let dueDate = dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    var isUrgent: Bool {
        guard let dueDate = dueDate else { return false }
        let timeInterval = dueDate.timeIntervalSinceNow
        return timeInterval <= 86400 && timeInterval > 0 // Within 24 hours
    }
}
