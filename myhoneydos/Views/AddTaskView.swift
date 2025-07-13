//
//  AddTaskView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftUI
import SwiftData

struct EnhancedAddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [TaskCategory]
    @Query private var tags: [TaskTag]
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var priority = 3
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    @State private var selectedCategory: TaskCategory?
    @State private var selectedTags: Set<UUID> = []
    @State private var supplies: [SupplyItem] = []
    @State private var showingAddSupply = false
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    // Temporary supply item for the form
    struct SupplyItem: Identifiable {
        let id = UUID()
        var name: String
        var quantity: Int
        var estimatedCost: Double?
        var supplier: String?
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
                        
                        // Category Section
                        categorySection
                        
                        // Priority Section
                        prioritySection
                        
                        // Due Date Section
                        dueDateSection
                        
                        // Tags Section
                        tagsSection
                        
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
            AddEnhancedSupplySheet { supply in
                supplies.append(supply)
            }
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
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // No category option
                    CategorySelectionCard(
                        category: nil,
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(categories, id: \.id) { category in
                        CategorySelectionCard(
                            category: category,
                            isSelected: selectedCategory?.id == category.id
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
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
    
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Due Date")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 16) {
                // Toggle for due date
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Set due date")
                            .font(.subheadline)
                            .foregroundColor(themeManager.primaryText)
                        
                        Text("Add a deadline for this task")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $hasDueDate)
                        .tint(themeManager.accentColor)
                }
                
                // Date picker (shown when toggle is on)
                if hasDueDate {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Date & Time")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        DatePicker(
                            "Due Date",
                            selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ),
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .tint(themeManager.accentColor)
                        
                        // Quick date options
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                QuickDateButton(title: "Today", date: Calendar.current.startOfDay(for: Date())) {
                                    dueDate = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())
                                }
                                
                                QuickDateButton(title: "Tomorrow", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!) {
                                    dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!)
                                }
                                
                                QuickDateButton(title: "Next Week", date: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!) {
                                    dueDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .transition(.slide)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
        .animation(.easeInOut(duration: 0.3), value: hasDueDate)
        .onChange(of: hasDueDate) {
            if hasDueDate && dueDate == nil {
                dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            } else if !hasDueDate {
                dueDate = nil
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            if tags.isEmpty {
                Text("No tags available")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryText)
                    .opacity(0.7)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(tags, id: \.id) { tag in
                        TagSelectionCard(
                            tag: tag,
                            isSelected: selectedTags.contains(tag.id)
                        ) {
                            if selectedTags.contains(tag.id) {
                                selectedTags.remove(tag.id)
                            } else {
                                selectedTags.insert(tag.id)
                            }
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
                    
                    Text("Tap 'Add Supply' to include supplies for this task")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                        .opacity(0.5)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(supplies) { supply in
                        EnhancedSupplyRowView(supply: supply) {
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
    
    private func deleteSupply(_ supply: SupplyItem) {
        supplies.removeAll { $0.id == supply.id }
    }
    
    private func createTask() {
        let selectedTagObjects = tags.filter { selectedTags.contains($0.id) }
        
        dataManager.createTask(
            title: title,
            description: taskDescription,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            category: selectedCategory,
            tags: selectedTagObjects,
            in: modelContext
        )
        
        // Note: We'll need to get the created task to add supplies
        // For now, we'll create a simple task and then add supplies
        dismiss()
    }
}

// MARK: - Supporting Views
struct QuickDateButton: View {
    let title: String
    let date: Date
    let action: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(themeManager.accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.accentColor.opacity(0.1))
                )
        }
    }
}

struct TagSelectionCard: View {
    let tag: TaskTag
    let isSelected: Bool
    let onTap: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text("🏷️")
                    .font(.caption)
                
                Text(tag.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? themeManager.accentColor.opacity(0.3) : themeManager.tertiaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(AnimationManager.cardPress, value: isSelected)
    }
}

struct EnhancedSupplyRowView: View {
    let supply: EnhancedAddTaskView.SupplyItem
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
                
                HStack(spacing: 8) {
                    Text("Qty: \(supply.quantity)")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                    
                    if let cost = supply.estimatedCost {
                        Text("$\(cost, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    if let supplier = supply.supplier, !supplier.isEmpty {
                        Text("• \(supplier)")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
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

struct AddEnhancedSupplySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var supplyName = ""
    @State private var quantity = 1
    @State private var estimatedCost: Double?
    @State private var costText = ""
    @State private var supplier = ""
    
    let onAdd: (EnhancedAddTaskView.SupplyItem) -> Void
    
    private let themeManager = ThemeManager.shared
    
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
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        HStack {
                            Stepper(value: $quantity, in: 1...999) {
                                Text("\(quantity)")
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
                        
                        TextField("$0.00", text: $costText)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .onChange(of: costText) {
                                estimatedCost = Double(costText)
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Supplier (Optional)")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryText)
                        
                        TextField("Enter supplier...", text: $supplier)
                            .textFieldStyle(CustomTextFieldStyle())
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
        }
    }
    
    private func addSupply() {
        guard !supplyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let supply = EnhancedAddTaskView.SupplyItem(
            name: supplyName.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            estimatedCost: estimatedCost,
            supplier: supplier.isEmpty ? nil : supplier
        )
        onAdd(supply)
        dismiss()
    }
}

// MARK: - Preview
struct EnhancedAddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedAddTaskView()
            .modelContainer(for: HoneyDoTask.self, inMemory: true)
    }
}
