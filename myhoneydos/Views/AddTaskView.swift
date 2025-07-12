//
//  AddTaskView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var priority = 3
    @State private var supplies: [SupplyItem] = []
    @State private var newSupplyName = ""
    @State private var newSupplyQuantity = 1
    @State private var showingAddSupply = false
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    // Temporary supply item for the form
    struct SupplyItem: Identifiable {
        let id = UUID()
        var name: String
        var quantity: Int
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with bee animation
                        headerView
                        
                        // Task Details Section
                        taskDetailsSection
                        
                        // Priority Section
                        prioritySection
                        
                        // Supplies Section
                        suppliesSection
                        
                        // Create Button
                        createButton
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.secondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        createTask()
                    }
                    .foregroundColor(themeManager.accentColor)
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingAddSupply) {
            AddSupplySheet(
                supplyName: $newSupplyName,
                supplyQuantity: $newSupplyQuantity,
                onAdd: addSupply
            )
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("🐝")
                .font(.system(size: 60))
                .beeWiggle()
            
            Text("Create New Honey Do")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryText)
            
            Text("What sweet task needs doing?")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
        }
    }
    
    private var taskDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Details")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 12) {
                // Title Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    TextField("Enter task title...", text: $title)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    TextField("Enter task description...", text: $taskDescription, axis: .vertical)
                        .textFieldStyle(CustomTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Priority Level")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 16) {
                // Priority Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Priority: \(priority)")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        Spacer()
                        
                        // Animated Hearts
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                Text(index <= priority ? "❤️" : "🤍")
                                    .font(.title3)
                                    .heartBeat(priority: priority)
                            }
                        }
                    }
                    
                    Slider(value: Binding(
                        get: { Double(priority) },
                        set: { priority = Int($0) }
                    ), in: 1...5, step: 1)
                    .tint(themeManager.priorityColor(for: priority))
                }
                
                // Priority Labels
                HStack {
                    Text("Low")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Spacer()
                    
                    Text("High")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var suppliesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Supplies Needed")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
                
                Button(action: { showingAddSupply = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Supply")
                    }
                    .font(.subheadline)
                    .foregroundColor(themeManager.accentColor)
                }
            }
            
            if supplies.isEmpty {
                VStack(spacing: 8) {
                    Text("🎒")
                        .font(.title)
                        .opacity(0.5)
                    
                    Text("No supplies added yet")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                        .opacity(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(supplies) { supply in
                        SupplyRowView(supply: supply) {
                            deleteSupply(supply)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var createButton: some View {
        Button(action: createTask) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                
                Text("Create Honey Do")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.honeyGradient)
            )
            .shadow(color: themeManager.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(title.isEmpty)
        .opacity(title.isEmpty ? 0.6 : 1.0)
        .scaleEffect(title.isEmpty ? 0.98 : 1.0)
        .animation(AnimationManager.cardPress, value: title.isEmpty)
    }
    
    private func addSupply() {
        guard !newSupplyName.isEmpty else { return }
        
        let supply = SupplyItem(name: newSupplyName, quantity: newSupplyQuantity)
        supplies.append(supply)
        
        // Reset form
        newSupplyName = ""
        newSupplyQuantity = 1
        showingAddSupply = false
    }
    
    private func deleteSupply(_ supply: SupplyItem) {
        supplies.removeAll { $0.id == supply.id }
    }
    
    private func createTask() {
        let task = HoneyDoTask(
            title: title,
            taskDescription: taskDescription,
            priority: priority
        )
        
        modelContext.insert(task)
        
        // Add supplies
        for supplyItem in supplies {
            let supply = Supply(name: supplyItem.name, quantity: supplyItem.quantity)
            supply.task = task
            task.supplies.append(supply)
            modelContext.insert(supply)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving task: \(error)")
        }
    }
}

// MARK: - Supporting Views
//struct CustomTextFieldStyle: TextFieldStyle {
//    private let themeManager = ThemeManager.shared
//    
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//            .padding()
//            .background(themeManager.tertiaryBackground)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
//            )
//    }
//}

struct SupplyRowView: View {
    let supply: AddTaskView.SupplyItem
    let onDelete: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            Text("📦")
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(supply.name)
                    .font(.subheadline)
                    .foregroundColor(themeManager.primaryText)
                
                Text("Quantity: \(supply.quantity)")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(themeManager.tertiaryBackground)
        .cornerRadius(8)
    }
}

struct AddSupplySheet: View {
    @Binding var supplyName: String
    @Binding var supplyQuantity: Int
    let onAdd: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Supply Name")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    TextField("Enter supply name...", text: $supplyName)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantity")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Stepper(value: $supplyQuantity, in: 1...999) {
                        Text("\(supplyQuantity)")
                            .font(.headline)
                            .foregroundColor(themeManager.primaryText)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Supply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd()
                    }
                    .disabled(supplyName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .modelContainer(for: HoneyDoTask.self, inMemory: true)
    }
}
