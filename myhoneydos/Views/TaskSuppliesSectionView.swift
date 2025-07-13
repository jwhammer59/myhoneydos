//
//  TaskSuppliesSectionView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/13/25.
//

import SwiftUI
import SwiftData

struct TaskSuppliesSection: View {
    @Bindable var task: HoneyDoTask
    let isEditing: Bool
    let onAddSupply: () -> Void
    let onEditSupply: (Supply) -> Void
    let onDeleteSupply: (Supply) -> Void
    let onToggleSupply: (Supply) -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SuppliesHeader(
                task: task,
                onAddSupply: onAddSupply
            )
            
            if task.supplies.isEmpty {
                EmptySuppliesView()
            } else {
                SuppliesList(
                    task: task,
                    isEditing: isEditing,
                    onEditSupply: onEditSupply,
                    onDeleteSupply: onDeleteSupply,
                    onToggleSupply: onToggleSupply
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
}

struct SuppliesHeader: View {
    let task: HoneyDoTask
    let onAddSupply: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Supplies")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryText)
                
                if !task.supplies.isEmpty {
                    let obtainedCount = task.supplies.filter { $0.isObtained }.count
                    Text("\(obtainedCount) of \(task.supplies.count) obtained")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                }
            }
            
            Spacer()
            
            Button(action: onAddSupply) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add")
                }
                .font(.subheadline)
                .foregroundColor(themeManager.accentColor)
            }
        }
    }
}

struct EmptySuppliesView: View {
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            Text("🎒")
                .font(.title)
                .opacity(0.5)
            
            Text("No supplies needed")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
                .opacity(0.7)
            
            Text("Tap 'Add' to include supplies for this task")
                .font(.caption)
                .foregroundColor(themeManager.secondaryText)
                .opacity(0.5)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct SuppliesList: View {
    let task: HoneyDoTask
    let isEditing: Bool
    let onEditSupply: (Supply) -> Void
    let onDeleteSupply: (Supply) -> Void
    let onToggleSupply: (Supply) -> Void
    
    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(task.supplies.sorted(by: { !$0.isObtained && $1.isObtained })) { supply in
                SupplyRow(
                    supply: supply,
                    isEditing: isEditing,
                    onEdit: { onEditSupply(supply) },
                    onDelete: { onDeleteSupply(supply) },
                    onToggle: { onToggleSupply(supply) }
                )
            }
        }
    }
}

struct SupplyRow: View {
    let supply: Supply
    let isEditing: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggle: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: supply.isObtained ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(supply.isObtained ? themeManager.statusColor(for: TaskStatus.completed) : themeManager.secondaryText)
            }
            
            // Supply info
            VStack(alignment: .leading, spacing: 2) {
                Text(supply.name)
                    .font(.subheadline)
                    .foregroundColor(supply.isObtained ? themeManager.secondaryText : themeManager.primaryText)
                    .strikethrough(supply.isObtained)
                
                Text("Quantity: \(supply.quantity)")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            // Action buttons
            if isEditing {
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(themeManager.accentColor)
                            .padding(4)
                            .background(Circle().fill(themeManager.accentColor.opacity(0.1)))
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(4)
                            .background(Circle().fill(Color.red.opacity(0.1)))
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(supply.isObtained ? themeManager.statusColor(for: TaskStatus.completed).opacity(0.1) : themeManager.tertiaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(supply.isObtained ? themeManager.statusColor(for: TaskStatus.completed).opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}
