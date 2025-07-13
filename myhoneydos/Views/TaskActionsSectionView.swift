//
//  TaskActionsSectionView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/13/25.
//

import SwiftUI
import SwiftData

struct TaskActionsSection: View {
    let task: HoneyDoTask
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            if task.status != TaskStatus.completed {
                CompleteTaskButton(onComplete: onComplete)
            }
            
            DeleteTaskButton(onDelete: onDelete)
        }
    }
}

struct CompleteTaskButton: View {
    let onComplete: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: onComplete) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                Text("Mark as Complete")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.statusColor(for: TaskStatus.completed))
            )
            .shadow(color: themeManager.statusColor(for: TaskStatus.completed).opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

struct DeleteTaskButton: View {
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onDelete) {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.title3)
                Text("Delete Task")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red)
            )
            .shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}
