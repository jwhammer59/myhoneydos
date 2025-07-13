//
//  TaskCategory.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftData
import Foundation

// MARK: - Task Category Model
@Model
final class TaskCategory {
    var id: UUID
    var name: String
    var icon: String
    var color: String
    var createdDate: Date
    var tasks: [HoneyDoTask]
    
    init(name: String, icon: String, color: String) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.createdDate = Date()
        self.tasks = []
    }
    
    static let defaultCategories: [TaskCategory] = [
        TaskCategory(name: "Home", icon: "🏠", color: "blue"),
        TaskCategory(name: "Work", icon: "💼", color: "orange"),
        TaskCategory(name: "Personal", icon: "👤", color: "green"),
        TaskCategory(name: "Shopping", icon: "🛒", color: "purple"),
        TaskCategory(name: "Health", icon: "🏥", color: "red"),
        TaskCategory(name: "Garden", icon: "🌱", color: "mint")
    ]
}
