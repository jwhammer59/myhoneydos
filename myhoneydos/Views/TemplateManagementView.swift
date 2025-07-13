//
//  TemplateManagementView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftUI
import SwiftData

// MARK: - Template List View
struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var templates: [TaskTemplate]
    @Query private var categories: [TaskCategory]
    
    @State private var showingCreateTemplate = false
    @State private var selectedTemplate: TaskTemplate?
    @State private var searchText = ""
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    var filteredTemplates: [TaskTemplate] {
        if searchText.isEmpty {
            return templates.sorted { $0.useCount > $1.useCount }
        } else {
            return templates.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.title.localizedCaseInsensitiveContains(searchText) ||
                template.taskDescription.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.useCount > $1.useCount }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                    
                    // Template List
                    if filteredTemplates.isEmpty {
                        emptyState
                    } else {
                        templateList
                    }
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateTemplate = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateTemplate) {
            CreateTemplateView()
        }
        .sheet(item: $selectedTemplate) { template in
            TemplateDetailView(template: template)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.secondaryText)
            
            TextField("Search templates...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.secondaryText)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(themeManager.tertiaryBackground)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("📄")
                .font(.system(size: 60))
                .opacity(0.5)
            
            Text(searchText.isEmpty ? "No Templates Yet" : "No Templates Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.primaryText)
            
            Text(searchText.isEmpty ? "Create templates to quickly add recurring tasks" : "Try adjusting your search terms")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
            
            if searchText.isEmpty {
                Button(action: { showingCreateTemplate = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Create First Template")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(themeManager.accentColor)
                    .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var templateList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredTemplates) { template in
                    TemplateCardView(template: template) {
                        selectedTemplate = template
                    } onUse: {
                        useTemplate(template)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
    
    private func useTemplate(_ template: TaskTemplate) {
        _ = dataManager.createTaskFromTemplate(template, in: modelContext)
        dismiss()
        
        // Show success feedback
        withAnimation(.spring()) {
            // Could add haptic feedback here
        }
    }
}

// MARK: - Template Card View
struct TemplateCardView: View {
    let template: TaskTemplate
    let onTap: () -> Void
    let onUse: () -> Void
    
    @State private var isPressed = false
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(template.title)
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                // Use count badge
                HStack(spacing: 4) {
                    Text("🔄")
                        .font(.caption)
                    Text("\(template.useCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(themeManager.accentColor.opacity(0.2))
                .cornerRadius(8)
            }
            
            // Description
            if !template.taskDescription.isEmpty {
                Text(template.taskDescription)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)
            }
            
            // Category and priority
            HStack {
                // Category
                if let category = template.category {
                    HStack(spacing: 4) {
                        Text(category.icon)
                            .font(.caption)
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(themeManager.primaryText)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(themeManager.tertiaryBackground)
                    .cornerRadius(4)
                }
                
                // Priority
                HStack(spacing: 2) {
                    ForEach(1...template.priority, id: \.self) { _ in
                        Text("❤️")
                            .font(.caption2)
                    }
                }
                
                Spacer()
                
                // Supplies count
                if !template.supplies.isEmpty {
                    HStack(spacing: 4) {
                        Text("🎒")
                            .font(.caption2)
                        Text("\(template.supplies.count)")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
            }
            
            // Footer
            HStack {
                Text("Created \(template.createdDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(themeManager.secondaryText)
                
                Spacer()
                
                // Use button
                Button(action: onUse) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Use Template")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.accentColor)
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.secondaryBackground)
                .shadow(color: Color.black.opacity(0.1), radius: isPressed ? 2 : 4, x: 0, y: isPressed ? 1 : 2)
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
    }
}

// MARK: - Create Template View
struct CreateTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [TaskCategory]
    
    @State private var templateName = ""
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var priority = 3
    @State private var selectedCategory: TaskCategory?
    @State private var supplies: [SupplyTemplateItem] = []
    @State private var showingAddSupply = false
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    struct SupplyTemplateItem: Identifiable {
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
                        // Header
                        headerView
                        
                        // Template Details
                        templateDetailsSection
                        
                        // Priority Section
                        prioritySection
                        
                        // Category Section
                        categorySection
                        
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
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        createTemplate()
                    }
                    .disabled(templateName.isEmpty || taskTitle.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingAddSupply) {
            AddSupplyTemplateSheet { supply in
                supplies.append(supply)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("📄")
                .font(.system(size: 60))
            
            Text("Create Template")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryText)
            
            Text("Create reusable templates for recurring tasks")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    private var templateDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Template Details")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Template Name")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryText)
                
                TextField("Enter template name...", text: $templateName)
                    .textFieldStyle(CustomTextFieldStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var taskDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Details")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Title")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    TextField("Enter task title...", text: $taskTitle)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
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
            Text("Default Priority")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Priority: \(priority)")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Spacer()
                    
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
    
    private var suppliesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Default Supplies")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryText)
                
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
            
            if supplies.isEmpty {
                VStack(spacing: 8) {
                    Text("🎒")
                        .font(.title)
                        .opacity(0.5)
                    
                    Text("No supplies added")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                        .opacity(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(supplies) { supply in
                        SupplyTemplateRowView(supply: supply) {
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
        Button(action: createTemplate) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                
                Text("Create Template")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(templateName.isEmpty || taskTitle.isEmpty ?
                          LinearGradient(colors: [themeManager.secondaryText], startPoint: .leading, endPoint: .trailing) :
                            themeManager.honeyGradient)
            )
            .shadow(color: themeManager.accentColor.opacity(0.3), radius: templateName.isEmpty || taskTitle.isEmpty ? 0 : 10, x: 0, y: 5)
        }
        .disabled(templateName.isEmpty || taskTitle.isEmpty)
        .animation(AnimationManager.cardPress, value: templateName.isEmpty || taskTitle.isEmpty)
    }
    
    private func deleteSupply(_ supply: SupplyTemplateItem) {
        supplies.removeAll { $0.id == supply.id }
    }
    
    private func createTemplate() {
        let supplyTemplates = supplies.map { item in
            SupplyTemplate(
                name: item.name,
                quantity: item.quantity,
                estimatedCost: item.estimatedCost,
                supplier: item.supplier
            )
        }
        
        _ = dataManager.createTemplate(
            name: templateName,
            title: taskTitle,
            description: taskDescription,
            priority: priority,
            category: selectedCategory,
            supplies: supplyTemplates,
            in: modelContext
        )
        
        dismiss()
    }
}

// MARK: - Category Selection Card
struct CategorySelectionCard: View {
    let category: TaskCategory?
    let isSelected: Bool
    let onTap: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            Text(category?.icon ?? "❌")
                .font(.title2)
            
            Text(category?.name ?? "None")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(themeManager.primaryText)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? themeManager.accentColor.opacity(0.3) : themeManager.tertiaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(AnimationManager.cardPress, value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Supply Template Row View
struct SupplyTemplateRowView: View {
    let supply: CreateTemplateView.SupplyTemplateItem
    let onDelete: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
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

// MARK: - Add Supply Template Sheet
struct AddSupplyTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var supplyName = ""
    @State private var quantity = 1
    @State private var estimatedCost: Double?
    @State private var costText = ""
    @State private var supplier = ""
    
    let onAdd: (CreateTemplateView.SupplyTemplateItem) -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
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
                        
                        Stepper(value: $quantity, in: 1...999) {
                            Text("\(quantity)")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryText)
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
                        let supply = CreateTemplateView.SupplyTemplateItem(
                            name: supplyName,
                            quantity: quantity,
                            estimatedCost: estimatedCost,
                            supplier: supplier.isEmpty ? nil : supplier
                        )
                        onAdd(supply)
                        dismiss()
                    }
                    .disabled(supplyName.isEmpty)
                    .foregroundColor(supplyName.isEmpty ? themeManager.secondaryText : themeManager.accentColor)
                }
            }
        }
    }
}

// MARK: - Template Detail View
struct TemplateDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var template: TaskTemplate
    @State private var showingEditMode = false
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Template Info
                    templateInfoView
                    
                    // Supplies
                    if !template.supplies.isEmpty {
                        suppliesView
                    }
                    
                    // Actions
                    actionsView
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditMode = true
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("📄")
                .font(.system(size: 50))
            
            Text(template.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryText)
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("🔄")
                        .font(.caption)
                    Text("Used \(template.useCount) times")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Text("•")
                    .foregroundColor(themeManager.secondaryText)
                
                Text("Created \(template.createdDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
            }
        }
    }
    
    private var templateInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Template Details")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            VStack(spacing: 12) {
                InfoRow(label: "Title", value: template.title)
                
                if !template.taskDescription.isEmpty {
                    InfoRow(label: "Description", value: template.taskDescription)
                }
                
                HStack {
                    Text("Priority:")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Text(index <= template.priority ? "❤️" : "🤍")
                                .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                }
                
                if let category = template.category {
                    InfoRow(label: "Category", value: "\(category.icon) \(category.name)")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var suppliesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Default Supplies")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            LazyVStack(spacing: 8) {
                ForEach(template.supplies, id: \.id) { supply in
                    HStack {
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
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(themeManager.tertiaryBackground)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var actionsView: some View {
        VStack(spacing: 12) {
            Button(action: useTemplate) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Task from Template")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeManager.accentColor)
                .cornerRadius(16)
            }
            
            Button(action: deleteTemplate) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                    Text("Delete Template")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(16)
            }
        }
    }
    
    private func useTemplate() {
        _ = dataManager.createTaskFromTemplate(template, in: modelContext)
        dismiss()
    }
    
    private func deleteTemplate() {
        dataManager.deleteTemplate(template, in: modelContext)
        dismiss()
    }
}

// MARK: - Info Row Helper
struct InfoRow: View {
    let label: String
    let value: String
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(themeManager.secondaryText)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(themeManager.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
struct TemplateListView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateListView()
            .modelContainer(for: TaskTemplate.self, inMemory: true)
    }
}
