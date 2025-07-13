//
//  TaskTag.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftData
import Foundation

// MARK: - Task Tag Model
@Model
final class TaskTag {
    var id: UUID
    var name: String
    var color: String
    var createdDate: Date
    var tasks: [HoneyDoTask]
    
    init(name: String, color: String) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.createdDate = Date()
        self.tasks = []
    }
}
