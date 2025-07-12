//
//  HoneyDoTask.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftData
import Foundation

@Model
final class HoneyDoTask {
    var id: UUID
    var title: String
    var taskDescription: String
    var priority: Int // 1-5 heart rating
    var status: TaskStatus
    var createdDate: Date
    var completedDate: Date?
    var supplies: [Supply]
    
    init(title: String, taskDescription: String = "", priority: Int = 1, status: TaskStatus = .toDo) {
        self.id = UUID()
        self.title = title
        self.taskDescription = taskDescription
        self.priority = max(1, min(5, priority)) // Ensure priority is between 1-5
        self.status = status
        self.createdDate = Date()
        self.completedDate = nil
        self.supplies = []
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var priorityHearts: String {
        String(repeating: "❤️", count: priority) + String(repeating: "🤍", count: 5 - priority)
    }
}
