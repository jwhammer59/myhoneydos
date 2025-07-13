//
//  TaskInfoSectionView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/13/25.
//

import SwiftUI
import SwiftData

struct TaskInfoSection: View {
    @Bindable var task: HoneyDoTask
    let isEditing: Bool
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Details")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 16) {
                // Title
                TaskTitleField(task: task, isEditing: isEditing)
                
                // Description
                TaskDescriptionField(task: task, isEditing: isEditing)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
}

struct TaskTitleField: View {
    @Bindable var task: HoneyDoTask
    let isEditing: Bool
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
            
            if isEditing {
                TextField("Task title", text: $task.title)
                    .textFieldStyle(CustomTextFieldStyle())
            } else {
                Text(task.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct TaskDescriptionField: View {
    @Bindable var task: HoneyDoTask
    let isEditing: Bool
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
            
            if isEditing {
                TextField("Task description", text: $task.taskDescription, axis: .vertical)
                    .textFieldStyle(CustomTextFieldStyle())
                    .lineLimit(3...6)
            } else {
                if task.taskDescription.isEmpty {
                    Text("No description")
                        .font(.body)
                        .foregroundColor(themeManager.secondaryText)
                        .opacity(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(task.taskDescription)
                        .font(.body)
                        .foregroundColor(themeManager.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
