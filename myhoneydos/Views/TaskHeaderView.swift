//
//  TaskHeaderView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/13/25.
//

import SwiftUI
import SwiftData

struct TaskHeaderView: View {
    @Bindable var task: HoneyDoTask
    @State private var showingStatusPicker = false
    let onStatusChange: (TaskStatus) -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Status with large icon - tappable to change
            Button(action: { showingStatusPicker = true }) {
                VStack(spacing: 8) {
                    Text(task.status.icon)
                        .font(.system(size: 50))
                        .scaleEffect(task.status == TaskStatus.completed ? 1.2 : 1.0)
                        .animation(AnimationManager.taskComplete, value: task.status)
                    
                    Text(task.status.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.statusColor(for: task.status))
                    
                    Text("Tap to change")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                        .opacity(0.7)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .background(themeManager.secondaryText.opacity(0.3))
            
            // Date information
            VStack(spacing: 4) {
                Text("Created \(task.createdDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                
                if let completedDate = task.completedDate {
                    Text("Completed \(completedDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(themeManager.statusColor(for: TaskStatus.completed))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.statusColor(for: task.status).opacity(0.3), lineWidth: 2)
                )
        )
        .confirmationDialog("Change Status", isPresented: $showingStatusPicker) {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button("\(status.icon) \(status.rawValue)") {
                    onStatusChange(status)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
