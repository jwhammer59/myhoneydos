//
//  TaskPrioritySectionView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/13/25.
//

import SwiftUI
import SwiftData

struct TaskPrioritySection: View {
    @Bindable var task: HoneyDoTask
    let isEditing: Bool
    
    private let themeManager = ThemeManager.shared
    
    var priorityDescription: String {
        switch task.priority {
        case 1: return "Low priority - can wait for convenient time"
        case 2: return "Minor priority - do when you have time"
        case 3: return "Medium priority - should be done soon"
        case 4: return "High priority - important task to complete"
        case 5: return "Critical priority - urgent and important!"
        default: return "Medium priority"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Priority Level")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 12) {
                // Priority display/editor
                HStack {
                    Text("Priority:")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Spacer()
                    
                    if isEditing {
                        PriorityEditor(task: task)
                    } else {
                        PriorityDisplay(priority: task.priority)
                    }
                }
                
                // Priority description
                Text(priorityDescription)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
}

struct PriorityEditor: View {
    @Bindable var task: HoneyDoTask
    
    var body: some View {
        Stepper(value: $task.priority, in: 1...5) {
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Text(index <= task.priority ? "❤️" : "🤍")
                        .font(.title3)
                        .heartBeat(priority: task.priority)
                }
            }
        }
    }
}

struct PriorityDisplay: View {
    let priority: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Text(index <= priority ? "❤️" : "🤍")
                    .font(.title3)
                    .heartBeat(priority: priority)
            }
        }
    }
}
