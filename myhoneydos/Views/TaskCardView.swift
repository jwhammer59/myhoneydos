//
//  TaskCardView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftUI
import SwiftData

struct EnhancedTaskCardView: View {
    @Environment(\.modelContext) private var modelContext
    let task: HoneyDoTask
    let isSelected: Bool
    let isSelectionMode: Bool
    let onTap: () -> Void
    let onSelect: () -> Void
    
    @State private var isPressed = false
    @State private var showingStatusMenu = false
    @State private var showingQuickActions = false
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with selection and status
            headerSection
            
            // Title and description
            titleSection
            
            // Category and tags
            if task.category != nil || !task.tags.isEmpty {
                categoryTagSection
            }
            
            // Priority and due date
            priorityDueDateSection
            
            // Supplies summary
            if !task.supplies.isEmpty {
                suppliesSection
            }
            
            // Footer with actions
            footerSection
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? themeManager.accentColor.opacity(0.1) : themeManager.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? themeManager.accentColor :
                                (task.isOverdue ? Color.red.opacity(0.5) :
                                    task.isUrgent ? Color.orange.opacity(0.5) : Color.clear),
                            lineWidth: isSelected ? 2 : (task.isOverdue || task.isUrgent ? 1 : 0)
                        )
                )
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
            if isSelectionMode {
                onSelect()
            } else {
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
        }
        .onLongPressGesture {
            if !isSelectionMode {
                onSelect()
            }
        }
        .contextMenu {
            contextMenuItems
        }
        .confirmationDialog("Change Status", isPresented: $showingStatusMenu) {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button("\(status.icon) \(status.rawValue)") {
                    changeStatus(to: status)
                }
            }
        }
        .confirmationDialog("Quick Actions", isPresented: $showingQuickActions) {
            Button("Duplicate Task") {
                duplicateTask()
            }
            Button("Create Template") {
                createTemplate()
            }
            if task.status != .completed {
                Button("Complete Task") {
                    completeTask()
                }
            }
            Button("Delete Task", role: .destructive) {
                deleteTask()
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            // Selection indicator
            if isSelectionMode {
                Button(action: onSelect) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? themeManager.accentColor : themeManager.secondaryText)
                }
                .animation(AnimationManager.cardPress, value: isSelected)
            }
            
            Spacer()
            
            // Overdue/Urgent indicator
            if task.isOverdue {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text("OVERDUE")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red)
                .cornerRadius(8)
            } else if task.isUrgent {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text("DUE SOON")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange)
                .cornerRadius(8)
            }
            
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
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
                .lineLimit(2)
                .strikethrough(task.isCompleted, color: themeManager.secondaryText)
            
            if !task.taskDescription.isEmpty {
                Text(task.taskDescription)
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(3)
                    .opacity(task.isCompleted ? 0.6 : 1.0)
            }
        }
    }
    
    private var categoryTagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category
            if let category = task.category {
                HStack(spacing: 6) {
                    Text(category.icon)
                        .font(.caption)
                    Text(category.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.primaryText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(themeManager.priorityColor(for: 3).opacity(0.2))
                )
            }
            
            // Tags
            if !task.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(task.tags, id: \.id) { tag in
                            HStack(spacing: 4) {
                                Text("🏷️")
                                    .font(.caption2)
                                Text(tag.name)
                                    .font(.caption2)
                                    .foregroundColor(themeManager.primaryText)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(themeManager.secondaryText.opacity(0.1))
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var priorityDueDateSection: some View {
        HStack {
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
            }
            
            Spacer()
            
            // Due Date
            if let dueDate = task.dueDate {
                HStack(spacing: 4) {
                    Image(systemName: task.isOverdue ? "calendar.badge.exclamationmark" : "calendar")
                        .font(.caption)
                        .foregroundColor(task.isOverdue ? .red : themeManager.secondaryText)
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(dueDateText(dueDate))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(task.isOverdue ? .red : themeManager.primaryText)
                        
                        Text(relativeDateText(dueDate))
                            .font(.caption2)
                            .foregroundColor(task.isOverdue ? .red : themeManager.secondaryText)
                    }
                }
            }
        }
    }
    
    private var suppliesSection: some View {
        HStack {
            Text("🎒")
                .font(.caption)
            
            let obtainedCount = task.supplies.filter { $0.isObtained }.count
            let totalCount = task.supplies.count
            
            Text("\(obtainedCount)/\(totalCount) supplies")
                .font(.caption)
                .foregroundColor(themeManager.secondaryText)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(themeManager.secondaryText.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(themeManager.statusColor(for: .completed))
                        .frame(width: geometry.size.width * (Double(obtainedCount) / Double(totalCount)), height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: obtainedCount)
                }
            }
            .frame(height: 4)
            .frame(maxWidth: 60)
            
            Spacer()
        }
    }
    
    private var footerSection: some View {
        HStack {
            Text(task.createdDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(themeManager.secondaryText)
            
            Spacer()
            
            // Quick Action Buttons
            HStack(spacing: 12) {
                // Quick Complete Button
                if task.status != .completed {
                    Button(action: { completeTask() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle")
                                .font(.caption)
                            Text("Complete")
                                .font(.caption)
                        }
                        .foregroundColor(themeManager.statusColor(for: .completed))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(themeManager.statusColor(for: .completed).opacity(0.2))
                        )
                    }
                }
                
                // More Actions Button
                Button(action: { showingQuickActions = true }) {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                        .padding(4)
                        .background(Circle().fill(themeManager.tertiaryBackground))
                }
            }
        }
    }
    
    private var contextMenuItems: some View {
        Group {
            Button(action: duplicateTask) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            
            Button(action: createTemplate) {
                Label("Create Template", systemImage: "square.on.square.dashed")
            }
            
            if task.status != .completed {
                Button(action: completeTask) {
                    Label("Complete", systemImage: "checkmark.circle")
                }
            }
            
            Divider()
            
            Button(action: deleteTask) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Helper Functions
    private func dueDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
    
    private func relativeDateText(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func completeTask() {
        withAnimation(AnimationManager.taskComplete) {
            task.status = .completed
            task.completedDate = Date()
            dataManager.updateTask(task, in: modelContext)
        }
    }
    
    private func changeStatus(to status: TaskStatus) {
        withAnimation(AnimationManager.taskComplete) {
            task.status = status
            if status == .completed {
                task.completedDate = Date()
            } else {
                task.completedDate = nil
            }
            dataManager.updateTask(task, in: modelContext)
        }
    }
    
    private func duplicateTask() {
        withAnimation(AnimationManager.cardAppear) {
            _ = dataManager.duplicateTask(task, in: modelContext)
        }
    }
    
    private func createTemplate() {
        let templateName = "\(task.title) Template"
        _ = dataManager.createTemplateFromTask(task, templateName: templateName, in: modelContext)
    }
    
    private func deleteTask() {
        withAnimation(AnimationManager.listItemDelete) {
            dataManager.deleteTask(task, in: modelContext)
        }
    }
}

// MARK: - Preview
struct EnhancedTaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: HoneyDoTask.self, configurations: config)
        
        let category = TaskCategory(name: "Home", icon: "🏠", color: "blue")
        let tag1 = TaskTag(name: "Urgent", color: "red")
        let tag2 = TaskTag(name: "DIY", color: "green")
        
        let sampleTask = HoneyDoTask(
            title: "Fix Kitchen Sink",
            taskDescription: "The kitchen sink is leaking and needs immediate attention",
            priority: 4,
            dueDate: Date().addingTimeInterval(86400), // Tomorrow
            category: category
        )
        sampleTask.tags = [tag1, tag2]
        
        let supply1 = Supply(name: "Wrench", quantity: 1, isObtained: true)
        let supply2 = Supply(name: "Pipe sealant", quantity: 1, isObtained: false)
        sampleTask.supplies = [supply1, supply2]
        
        container.mainContext.insert(category)
        container.mainContext.insert(tag1)
        container.mainContext.insert(tag2)
        container.mainContext.insert(sampleTask)
        container.mainContext.insert(supply1)
        container.mainContext.insert(supply2)
        
        return VStack(spacing: 16) {
            EnhancedTaskCardView(
                task: sampleTask,
                isSelected: false,
                isSelectionMode: false,
                onTap: {},
                onSelect: {}
            )
            
            EnhancedTaskCardView(
                task: sampleTask,
                isSelected: true,
                isSelectionMode: true,
                onTap: {},
                onSelect: {}
            )
        }
        .modelContainer(container)
        .padding()
    }
}
