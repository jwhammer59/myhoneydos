//
//  TaskCardView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftUI
import SwiftData

struct TaskCardView: View {
    @Environment(\.modelContext) private var modelContext
    let task: HoneyDoTask
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var showingStatusMenu = false
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(2)
                    
                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                            .lineLimit(3)
                    }
                }
                
                Spacer()
                
                // Status Button
                Button(action: { showingStatusMenu = true }) {
                    VStack(spacing: 2) {
                        Text(task.status.icon)
                            .font(.title2)
                        Text(task.status.rawValue)
                            .font(.caption2)
                            .foregroundColor(themeManager.statusColor(for: task.status))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.statusColor(for: task.status).opacity(0.2))
                    )
                }
                .scaleEffect(showingStatusMenu ? 1.1 : 1.0)
                .animation(AnimationManager.cardPress, value: showingStatusMenu)
            }
            
            // Priority Hearts
            HStack(spacing: 4) {
                Text("Priority:")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                
                ForEach(1...5, id: \.self) { index in
                    Text(index <= task.priority ? "❤️" : "🤍")
                        .font(.subheadline)
                        .heartBeat(priority: task.priority)
                }
                
                Spacer()
            }
            
            // Supplies Summary
            if !task.supplies.isEmpty {
                HStack {
                    Text("🎒")
                        .font(.caption)
                    Text("\(task.supplies.count) supplies")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                    
                    let obtainedCount = task.supplies.filter { $0.isObtained }.count
                    if obtainedCount > 0 {
                        Text("(\(obtainedCount) obtained)")
                            .font(.caption)
                            .foregroundColor(themeManager.statusColor(for: .completed))
                    }
                    
                    Spacer()
                }
            }
            
            // Footer with date and actions
            HStack {
                Text(task.createdDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                
                Spacer()
                
                // Quick Complete Button
                if task.status != .completed {
                    Button(action: { completeTask() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle")
                            Text("Complete")
                        }
                        .font(.caption)
                        .foregroundColor(themeManager.statusColor(for: .completed))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(themeManager.statusColor(for: .completed).opacity(0.2))
                        )
                    }
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(AnimationManager.cardPress, value: isPressed)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: isPressed ? 2 : 5,
                    x: 0,
                    y: isPressed ? 1 : 3
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AnimationManager.cardPress, value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
                onTap()
            }
        }
        .confirmationDialog("Change Status", isPresented: $showingStatusMenu) {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button("\(status.icon) \(status.rawValue)") {
                    changeStatus(to: status)
                }
            }
        }
    }
    
    private func completeTask() {
        withAnimation(AnimationManager.taskComplete) {
            dataManager.completeTask(task, in: modelContext)
        }
    }
    
    private func changeStatus(to status: TaskStatus) {
        withAnimation(AnimationManager.taskComplete) {
            dataManager.updateTaskStatus(task, to: status, in: modelContext)
        }
    }
}

// MARK: - Preview
struct TaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: HoneyDoTask.self, configurations: config)
        
        let sampleTask = HoneyDoTask(title: "Sample Task", taskDescription: "This is a sample task description", priority: 3)
        container.mainContext.insert(sampleTask)
        
        return TaskCardView(task: sampleTask, onTap: {})
            .modelContainer(container)
            .padding()
    }
}
