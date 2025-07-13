//
//  TaskStatus.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import Foundation

// MARK: - Enhanced Task Status
enum TaskStatus: String, CaseIterable, Codable {
    case toDo = "To Do"
    case inProgress = "In Progress"
    case completed = "Completed"
    case onHold = "On Hold"
    case cancelled = "Cancelled"
    
    var icon: String {
        switch self {
        case .toDo:
            return "🐝"
        case .inProgress:
            return "🍯"
        case .completed:
            return "✅"
        case .onHold:
            return "⏸️"
        case .cancelled:
            return "❌"
        }
    }
    
    var color: String {
        switch self {
        case .toDo:
            return "yellow"
        case .inProgress:
            return "orange"
        case .completed:
            return "green"
        case .onHold:
            return "gray"
        case .cancelled:
            return "red"
        }
    }
}
