//
//  TaskFilter.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import Foundation

// MARK: - Search Filter Options
enum TaskFilter: String, CaseIterable {
    case all = "All Tasks"
    case today = "Due Today"
    case overdue = "Overdue"
    case thisWeek = "This Week"
    case noDueDate = "No Due Date"
    case highPriority = "High Priority"
    case completed = "Completed"
    
    var icon: String {
        switch self {
        case .all: return "📋"
        case .today: return "📅"
        case .overdue: return "⚠️"
        case .thisWeek: return "🗓️"
        case .noDueDate: return "∞"
        case .highPriority: return "🔥"
        case .completed: return "✅"
        }
    }
}
