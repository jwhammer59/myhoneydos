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
    @State private var showingStatusPicker = false
    
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
                        headerView
                        
                        // Task Info Section
                        taskInfoSection
                        
                        // Priority Section
                        prioritySection
                        
                        // Supplies Section
                        suppliesSection
                        
                        // Actions Section
                        actionsSection
                        
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
                        withAnimation {
                            if isEditing {
                                saveChanges()
                            }
                            isEditing.toggle()
                        }
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
        .confirmationDialog("Change Status", isPresented: $showingStatusPicker) {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button("\(status.icon) \(status.rawValue)") {
                    changeStatus(to: status)
                }
            }
            Button("Cancel", role: .cancel) { }
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
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Status with large icon - tappable to change
            Button(action: { showingStatusPicker = true }) {
                VStack(spacing: 8) {
                    Text(task.status.icon)
                        .font(.system(size: 50))
                        .scaleEffect(task.status == .completed ? 1.2 : 1.0)
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
                        .foregroundColor(themeManager.statusColor(for: .completed))
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
    }
    
    private var taskInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Details")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 16) {
                // Title
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
                
                // Description
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
            
            VStack(spacing: 12) {
                // Priority display/editor
                HStack {
                    Text("Priority:")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Spacer()
                    
                    if isEditing {
                        Stepper(value: $task.priority, in: 1...5) {
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { index in
                                    Text(index <= task.priority ? "❤️" : "🤍")
                                        .font(.title3)
                                        .heartBeat(priority: task.priority)
                                }
                            }
                        }
                    } else {
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                Text(index <= task.priority ? "❤️" : "🤍")
                                    .font(.title3)
                                    .heartBeat(priority: task.priority)
                            }
                        }
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
    
    private var suppliesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                
                Button(action: { showingAddSupply = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.subheadline)
                    .foregroundColor(themeManager.accentColor)
                }
            }
            
            if task.supplies.isEmpty {
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
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(task.supplies.sorted(by: { !$0.isObtained && $1.isObtained })) { supply in
                        SupplyDetailRow(
                            supply: supply,
                            isEditing: isEditing,
                            onEdit: { editingSupply = supply },
                            onDelete: { deleteSupply(supply) },
                            onToggle: { toggleSupplyObtained(supply) }
                        )
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
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Status Change Buttons
            if task.status != .completed {
                Button(action: { completeTask() }) {
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
                            .fill(themeManager.statusColor(for: .completed))
                    )
                    .shadow(color: themeManager.statusColor(for: .completed).opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .scaleEffect(task.status == .completed ? 0.95 : 1.0)
                .animation(AnimationManager.taskComplete, value: task.status)
            }
            
            // Delete Button
            Button(action: { showingDeleteAlert = true }) {
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
    
    private var priorityDescription: String {
        switch task.priority {
        case 1: return "Low priority - can wait for convenient time"
        case 2: return "Minor priority - do when you have time"
        case 3: return "Medium priority - should be done soon"
        case 4: return "High priority - important task to complete"
        case 5: return "Critical priority - urgent and important!"
        default: return "Medium priority"
        }
    }
    
    private func saveChanges() {
        // Ensure title is not empty
        if task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            task.title = "Untitled Task"
        }
        dataManager.updateTask(task, in: modelContext)
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

// MARK: - Supporting Views
struct SupplyDetailRow: View {
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
                    .foregroundColor(supply.isObtained ? themeManager.statusColor(for: .completed) : themeManager.secondaryText)
            }
            .animation(AnimationManager.supplyCheck, value: supply.isObtained)
            
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
                .fill(supply.isObtained ? themeManager.statusColor(for: .completed).opacity(0.1) : themeManager.tertiaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(supply.isObtained ? themeManager.statusColor(for: .completed).opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Sheet Views
struct AddSupplyToTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let task: HoneyDoTask
    @State private var supplyName = ""
    @State private var supplyQuantity = 1
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
                .animation(AnimationManager.cardPress, value: supplyName.isEmpty)
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
                .animation(AnimationManager.cardPress, value: tempName.isEmpty)
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
            in: modelContext
        )
        dismiss()
    }
}

// MARK: - Custom Text Field Style (if not already defined elsewhere)
struct CustomTextFieldStyle: TextFieldStyle {
    private let themeManager = ThemeManager.shared
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(themeManager.tertiaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Preview
struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: HoneyDoTask.self, configurations: config)
        
        let sampleTask = HoneyDoTask(title: "Sample Task", taskDescription: "This is a detailed task description with multiple lines to test the layout and text wrapping functionality", priority: 4)
        let supply1 = Supply(name: "Hammer", quantity: 1)
        let supply2 = Supply(name: "Nails", quantity: 20, isObtained: true)
        let supply3 = Supply(name: "Wood planks", quantity: 5)
        sampleTask.supplies = [supply1, supply2, supply3]
        
        container.mainContext.insert(sampleTask)
        
        return TaskDetailView(task: sampleTask)
            .modelContainer(container)
    }
}
