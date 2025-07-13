//
//  TaskDueDateSectionView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/13/25.
//

import SwiftUI
import SwiftData

struct TaskDueDateSection: View {
    @Bindable var task: HoneyDoTask
    let isEditing: Bool
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Due Date")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            if isEditing {
                DueDateEditor(task: task)
            } else {
                DueDateDisplay(task: task)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
}

struct DueDateEditor: View {
    @Bindable var task: HoneyDoTask
    @State private var hasDueDate: Bool = false
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Set due date")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryText)
                
                Spacer()
                
                Toggle("", isOn: $hasDueDate)
                    .tint(themeManager.accentColor)
                    .onChange(of: hasDueDate) { _, newValue in
                        if newValue && task.dueDate == nil {
                            task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                        } else if !newValue {
                            task.dueDate = nil
                        }
                    }
            }
            
            if hasDueDate {
                DueDatePicker(task: task)
            }
        }
        .onAppear {
            hasDueDate = task.dueDate != nil
        }
    }
}

struct DueDatePicker: View {
    @Bindable var task: HoneyDoTask
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Date & Time")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
            
            DatePicker(
                "Due Date",
                selection: Binding(
                    get: { task.dueDate ?? Date() },
                    set: { task.dueDate = $0 }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(CompactDatePickerStyle())
            .tint(themeManager.accentColor)
        }
    }
}

struct DueDateDisplay: View {
    let task: HoneyDoTask
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let dueDate = task.dueDate {
                DueDateInfo(task: task, dueDate: dueDate)
            } else {
                NoDueDateView()
            }
        }
    }
}

struct DueDateInfo: View {
    let task: HoneyDoTask
    let dueDate: Date
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: task.isOverdue ? "calendar.badge.exclamationmark" : "calendar")
                    .font(.subheadline)
                    .foregroundColor(task.isOverdue ? .red : themeManager.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(task.isOverdue ? .red : themeManager.primaryText)
                    
                    Text(relativeDateText(dueDate))
                        .font(.caption)
                        .foregroundColor(task.isOverdue ? .red : themeManager.secondaryText)
                }
            }
            
            if task.isOverdue {
                OverdueIndicator()
            } else if task.isUrgent {
                UrgentIndicator()
            }
        }
    }
    
    private func relativeDateText(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct NoDueDateView: View {
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
            
            Text("No due date set")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
        }
    }
}

struct OverdueIndicator: View {
    var body: some View {
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
        .cornerRadius(6)
    }
}

struct UrgentIndicator: View {
    var body: some View {
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
        .cornerRadius(6)
    }
}
