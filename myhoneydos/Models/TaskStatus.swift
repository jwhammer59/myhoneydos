//
//  TaskStatus.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import Foundation

enum TaskStatus: String, CaseIterable, Codable {
    case toDo = "To Do"
    case inProgress = "In Progress"
    case completed = "Completed"
    
    var icon: String {
        switch self {
        case .toDo:
            return "🐝"
        case .inProgress:
            return "🍯"
        case .completed:
            return "✅"
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
        }
    }
}
