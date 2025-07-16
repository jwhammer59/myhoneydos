//
//  TaskDetailView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var task: HoneyDoTask
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingAddSupply = false
    @State private var editingSupply: Supply?
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with status
                        TaskHeaderView(task: task) { status in
                            changeStatus(to: status)
                        }
                        
                        // Task Info Section
                        TaskInfoSection(task: task, isEditing: isEditing)
                        
                        // Priority Section
                        TaskPrioritySection(task: task, isEditing: isEditing)
                        
                        // Due Date Section
                        TaskDueDateSection(task: task, isEditing: isEditing)
                        
                        // Supplies Section
                        TaskSuppliesSection(
                            task: task,
                            isEditing: isEditing,
                            onAddSupply: { showingAddSupply = true },
                            onEditSupply: { supply in editingSupply = supply },
                            onDeleteSupply: deleteSupply,
                            onToggleSupply: toggleSupplyObtained
                        )
                        
                        // Actions Section
                        TaskActionsSection(
                            task: task,
                            onComplete: completeTask,
                            onDelete: { showingDeleteAlert = true }
                        )
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        if isEditing {
                            saveChanges()
                        }
                        dismiss()
                    }
                    .foregroundColor(themeManager.secondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        if isEditing {
                            saveChanges()
                        }
                        isEditing.toggle()
                    }
                    .foregroundColor(themeManager.accentColor)
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingAddSupply) {
            AddSupplyToTaskSheet(task: task)
        }
        .sheet(item: $editingSupply) { supply in
            EditSupplySheet(supply: supply)
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteTask()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Functions
    private func saveChanges() {
        // Ensure title is not empty
        if task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            task.title = "Untitled Task"
        }
        dataManager.updateTask(task, in: modelContext)
    }
    
    private func completeTask() {
        withAnimation(AnimationManager.taskComplete) {
            task.status = TaskStatus.completed
            task.completedDate = Date()
            dataManager.updateTask(task, in: modelContext)
        }
    }
    
    private func changeStatus(to status: TaskStatus) {
        withAnimation(AnimationManager.taskComplete) {
            task.status = status
            if status == TaskStatus.completed {
                task.completedDate = Date()
            } else {
                task.completedDate = nil
            }
            dataManager.updateTask(task, in: modelContext)
        }
    }
    
    private func deleteTask() {
        dataManager.deleteTask(task, in: modelContext)
        dismiss()
    }
    
    private func deleteSupply(_ supply: Supply) {
        withAnimation(AnimationManager.listItemDelete) {
            dataManager.deleteSupply(supply, in: modelContext)
        }
    }
    
    private func toggleSupplyObtained(_ supply: Supply) {
        withAnimation(AnimationManager.supplyCheck) {
            dataManager.updateSupply(supply, isObtained: !supply.isObtained, in: modelContext)
        }
    }
}

// MARK: - Sheet Views (Keep these simple)
struct AddSupplyToTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let task: HoneyDoTask
    @State private var supplyName = ""
    @State private var supplyQuantity = 1
    @State private var supplyEstimatedCost: Double?
    @State private var supplySupplier: String?
    @FocusState private var isNameFieldFocused: Bool
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("📦")
                        .font(.system(size: 40))
                    
                    Text("Add Supply")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("What do you need for this task?")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Supply Name")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        TextField("Enter supply name...", text: $supplyName)
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($isNameFieldFocused)
                            .submitLabel(.done)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        HStack {
                            Stepper(value: $supplyQuantity, in: 1...999) {
                                Text("\(supplyQuantity)")
                                    .font(.headline)
                                    .foregroundColor(themeManager.primaryText)
                                    .frame(minWidth: 40)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.secondaryBackground)
                )
                
                Spacer()
                
                // Add Button
                Button(action: addSupply) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Supply")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(supplyName.isEmpty ? themeManager.secondaryText : themeManager.accentColor)
                    )
                }
                .disabled(supplyName.isEmpty)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.secondaryText)
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }
    
    private func addSupply() {
        guard !supplyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        dataManager.addSupply(
            to: task,
            name: supplyName.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: supplyQuantity,
            estimatedCost: supplyEstimatedCost,
            supplier: supplySupplier,
            in: modelContext
        )
        dismiss()
    }
}

struct EditSupplySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var supply: Supply
    @State private var tempName: String = ""
    @State private var tempQuantity: Int = 1
    @State private var tempEstimatedCost: Double?
    @State private var tempCostText: String = ""
    @State private var tempSupplier: String = ""
    @FocusState private var isNameFieldFocused: Bool
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("✏️")
                        .font(.system(size: 40))
                    
                    Text("Edit Supply")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryText)
                }
                .padding(.top)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Supply Name")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        TextField("Supply name", text: $tempName)
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($isNameFieldFocused)
                            .submitLabel(.done)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        HStack {
                            Stepper(value: $tempQuantity, in: 1...999) {
                                Text("\(tempQuantity)")
                                    .font(.headline)
                                    .foregroundColor(themeManager.primaryText)
                                    .frame(minWidth: 40)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated Cost (Optional)")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        TextField("0.00", text: $tempCostText)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .onChange(of: tempCostText) {
                                tempEstimatedCost = Double(tempCostText)
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Supplier (Optional)")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        TextField("Enter supplier...", text: $tempSupplier)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.secondaryBackground)
                )
                
                Spacer()
                
                // Save Button
                Button(action: saveSupply) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Changes")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tempName.isEmpty ? themeManager.secondaryText : themeManager.accentColor)
                    )
                }
                .disabled(tempName.isEmpty)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.secondaryText)
                }
            }
            .onAppear {
                tempName = supply.name
                tempQuantity = supply.quantity
                tempEstimatedCost = supply.estimatedCost
                tempCostText = String(supply.estimatedCost ?? 0.0)
                tempSupplier = supply.supplier ?? "N/A"
                isNameFieldFocused = true
            }
        }
    }
    
    private func saveSupply() {
        guard !tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        dataManager.updateSupply(
            supply,
            name: tempName.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: tempQuantity,
            estimatedCost: tempEstimatedCost,
            supplier: tempSupplier,
            in: modelContext
        )
        dismiss()
    }
}

// MARK: - Preview
struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: HoneyDoTask.self, configurations: config)
        
        let sampleTask = HoneyDoTask(
            title: "Sample Task",
            taskDescription: "This is a detailed task description with multiple lines to test the layout and text wrapping functionality",
            priority: 4,
            dueDate: Date().addingTimeInterval(86400)
        )
        let supply1 = Supply(name: "Hammer", quantity: 1)
        let supply2 = Supply(name: "Nails", quantity: 20, isObtained: true)
        let supply3 = Supply(name: "Wood planks", quantity: 5)
        sampleTask.supplies = [supply1, supply2, supply3]
        
        container.mainContext.insert(sampleTask)
        container.mainContext.insert(supply1)
        container.mainContext.insert(supply2)
        container.mainContext.insert(supply3)
        
        return TaskDetailView(task: sampleTask)
            .modelContainer(container)
    }
}
