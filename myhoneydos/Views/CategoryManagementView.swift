//
//  CategoryManagementView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [TaskCategory]
    
    @State private var showingCreateCategory = false
    @State private var editingCategory: TaskCategory?
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Categories Grid
                    if categories.isEmpty {
                        emptyState
                    } else {
                        categoriesGrid
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateCategory = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateCategory) {
            CreateCategoryView()
        }
        .sheet(item: $editingCategory) { category in
            EditCategoryView(category: category)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("🏷️")
                .font(.system(size: 60))
            
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryText)
            
            Text("Organize your tasks with categories")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.secondaryBackground)
        )
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("📂")
                .font(.system(size: 60))
                .opacity(0.5)
            
            Text("No Categories Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.primaryText)
            
            Text("Create categories to organize your tasks better")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: { showingCreateCategory = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create First Category")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(themeManager.accentColor)
                .cornerRadius(12)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var categoriesGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: 16)
            ], spacing: 16) {
                ForEach(categories) { category in
                    CategoryCard(category: category) {
                        editingCategory = category
                    } onDelete: {
                        deleteCategory(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
    
    private func deleteCategory(_ category: TaskCategory) {
        withAnimation {
            dataManager.deleteCategory(category, in: modelContext)
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: TaskCategory
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    @State private var isPressed = false
    
    private let themeManager = ThemeManager.shared
    
    var taskCount: Int {
        category.tasks.count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon and name
            VStack(spacing: 8) {
                Text(category.icon)
                    .font(.system(size: 40))
                
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center)
            }
            
            // Task count
            Text("\(taskCount) task\(taskCount == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
            
            // Actions
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 32, height: 32)
                        .background(themeManager.accentColor.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .disabled(taskCount > 0)
                .opacity(taskCount > 0 ? 0.5 : 1.0)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(colorFromString(category.color).opacity(0.3), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.1), radius: isPressed ? 2 : 5, x: 0, y: isPressed ? 1 : 3)
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
            }
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this category? This action cannot be undone.")
        }
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "mint": return .mint
        case "cyan": return .cyan
        case "indigo": return .indigo
        default: return themeManager.accentColor
        }
    }
}

// MARK: - Create Category View
struct CreateCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var categoryName = ""
    @State private var selectedIcon = "📋"
    @State private var selectedColor = "blue"
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    private let availableIcons = [
        "📋", "🏠", "💼", "🛒", "🏥", "🌱", "🚗", "💰", "🎓", "🍽️",
        "🎮", "📚", "🏃‍♂️", "🎨", "🔧", "💻", "📱", "🎵", "🎬", "✈️"
    ]
    
    private let availableColors = [
        ("blue", Color.blue),
        ("green", Color.green),
        ("orange", Color.orange),
        ("red", Color.red),
        ("purple", Color.purple),
        ("pink", Color.pink),
        ("yellow", Color.yellow),
        ("mint", Color.mint),
        ("cyan", Color.cyan),
        ("indigo", Color.indigo)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Category Name
                        nameSection
                        
                        // Icon Selection
                        iconSection
                        
                        // Color Selection
                        colorSection
                        
                        // Preview
                        previewSection
                        
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
                        createCategory()
                    }
                    .disabled(categoryName.isEmpty)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("🏷️")
                .font(.system(size: 60))
            
            Text("Create Category")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryText)
            
            Text("Add a new category to organize your tasks")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Name")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            TextField("Enter category name...", text: $categoryName)
                .textFieldStyle(CustomTextFieldStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Icon")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(availableIcons, id: \.self) { icon in
                    Button(action: { selectedIcon = icon }) {
                        Text(icon)
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIcon == icon ? themeManager.accentColor.opacity(0.3) : themeManager.tertiaryBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedIcon == icon ? themeManager.accentColor : Color.clear, lineWidth: 2)
                                    )
                            )
                    }
                    .scaleEffect(selectedIcon == icon ? 1.1 : 1.0)
                    .animation(AnimationManager.cardPress, value: selectedIcon == icon)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Color")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(availableColors, id: \.0) { colorName, color in
                    Button(action: { selectedColor = colorName }) {
                        Circle()
                            .fill(color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == colorName ? Color.white : Color.clear, lineWidth: 3)
                            )
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == colorName ? color : Color.clear, lineWidth: 2)
                            )
                    }
                    .scaleEffect(selectedColor == colorName ? 1.2 : 1.0)
                    .animation(AnimationManager.cardPress, value: selectedColor == colorName)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Text(selectedIcon)
                        .font(.system(size: 40))
                    
                    Text(categoryName.isEmpty ? "Category Name" : categoryName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("0 tasks")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding()
                .frame(width: 120, height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.tertiaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(colorFromString(selectedColor).opacity(0.5), lineWidth: 2)
                        )
                )
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var createButton: some View {
        Button(action: createCategory) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                
                Text("Create Category")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(categoryName.isEmpty ?
                          LinearGradient(colors: [themeManager.secondaryText], startPoint: .leading, endPoint: .trailing) :
                            themeManager.honeyGradient)
            )
            .shadow(color: themeManager.accentColor.opacity(0.3), radius: categoryName.isEmpty ? 0 : 10, x: 0, y: 5)
        }
        .disabled(categoryName.isEmpty)
        .animation(AnimationManager.cardPress, value: categoryName.isEmpty)
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "mint": return .mint
        case "cyan": return .cyan
        case "indigo": return .indigo
        default: return themeManager.accentColor
        }
    }
    
    private func createCategory() {
        _ = dataManager.createCategory(
            name: categoryName,
            icon: selectedIcon,
            color: selectedColor,
            in: modelContext
        )
        dismiss()
    }
}

// MARK: - Edit Category View
struct EditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var category: TaskCategory
    @State private var categoryName: String = ""
    @State private var selectedIcon: String = ""
    @State private var selectedColor: String = ""
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    private let availableIcons = [
        "📋", "🏠", "💼", "🛒", "🏥", "🌱", "🚗", "💰", "🎓", "🍽️",
        "🎮", "📚", "🏃‍♂️", "🎨", "🔧", "💻", "📱", "🎵", "🎬", "✈️"
    ]
    
    private let availableColors = [
        ("blue", Color.blue),
        ("green", Color.green),
        ("orange", Color.orange),
        ("red", Color.red),
        ("purple", Color.purple),
        ("pink", Color.pink),
        ("yellow", Color.yellow),
        ("mint", Color.mint),
        ("cyan", Color.cyan),
        ("indigo", Color.indigo)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Category Name
                        nameSection
                        
                        // Icon Selection
                        iconSection
                        
                        // Color Selection
                        colorSection
                        
                        // Preview
                        previewSection
                        
                        // Save Button
                        saveButton
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
                        saveChanges()
                    }
                    .disabled(categoryName.isEmpty)
                }
            }
            .onAppear {
                categoryName = category.name
                selectedIcon = category.icon
                selectedColor = category.color
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("✏️")
                .font(.system(size: 60))
            
            Text("Edit Category")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryText)
            
            Text("Update your category details")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Name")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            TextField("Enter category name...", text: $categoryName)
                .textFieldStyle(CustomTextFieldStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Icon")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(availableIcons, id: \.self) { icon in
                    Button(action: { selectedIcon = icon }) {
                        Text(icon)
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIcon == icon ? themeManager.accentColor.opacity(0.3) : themeManager.tertiaryBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedIcon == icon ? themeManager.accentColor : Color.clear, lineWidth: 2)
                                    )
                            )
                    }
                    .scaleEffect(selectedIcon == icon ? 1.1 : 1.0)
                    .animation(AnimationManager.cardPress, value: selectedIcon == icon)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Color")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(availableColors, id: \.0) { colorName, color in
                    Button(action: { selectedColor = colorName }) {
                        Circle()
                            .fill(color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == colorName ? Color.white : Color.clear, lineWidth: 3)
                            )
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == colorName ? color : Color.clear, lineWidth: 2)
                            )
                    }
                    .scaleEffect(selectedColor == colorName ? 1.2 : 1.0)
                    .animation(AnimationManager.cardPress, value: selectedColor == colorName)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Text(selectedIcon)
                        .font(.system(size: 40))
                    
                    Text(categoryName.isEmpty ? "Category Name" : categoryName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("\(category.tasks.count) task\(category.tasks.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding()
                .frame(width: 120, height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.tertiaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(colorFromString(selectedColor).opacity(0.5), lineWidth: 2)
                        )
                )
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
        )
    }
    
    private var saveButton: some View {
        Button(action: saveChanges) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                
                Text("Save Changes")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(categoryName.isEmpty ?
                          LinearGradient(colors: [themeManager.secondaryText], startPoint: .leading, endPoint: .trailing) :
                            themeManager.honeyGradient)
            )
            .shadow(color: themeManager.accentColor.opacity(0.3), radius: categoryName.isEmpty ? 0 : 10, x: 0, y: 5)
        }
        .disabled(categoryName.isEmpty)
        .animation(AnimationManager.cardPress, value: categoryName.isEmpty)
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "mint": return .mint
        case "cyan": return .cyan
        case "indigo": return .indigo
        default: return themeManager.accentColor
        }
    }
    
    private func saveChanges() {
        category.name = categoryName
        category.icon = selectedIcon
        category.color = selectedColor
        dataManager.updateCategory(category, in: modelContext)
        dismiss()
    }
}

// MARK: - Filter View
struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: TaskCategory?
    @Binding var selectedFilter: TaskFilter?
    @Binding var sortOption: ContentView.SortOption
    
    @Query private var categories: [TaskCategory]
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Category Filter
                VStack(alignment: .leading, spacing: 16) {
                    Text("Filter by Category")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // All categories option
                            FilterCategoryCard(
                                category: nil,
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(categories) { category in
                                FilterCategoryCard(
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
                
                // Quick Filters
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Filters")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryText)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            FilterOptionCard(
                                filter: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = selectedFilter == filter ? nil : filter
                            }
                        }
                    }
                }
                
                // Sort Options
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sort By")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryText)
                    
                    VStack(spacing: 8) {
                        ForEach(ContentView.SortOption.allCases, id: \.self) { option in
                            Button(action: { sortOption = option }) {
                                HStack {
                                    Text(option.rawValue)
                                        .foregroundColor(themeManager.primaryText)
                                    
                                    Spacer()
                                    
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(themeManager.accentColor)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(sortOption == option ? themeManager.accentColor.opacity(0.2) : themeManager.tertiaryBackground)
                                )
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Filters & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Filter Cards
struct FilterCategoryCard: View {
    let category: TaskCategory?
    let isSelected: Bool
    let onTap: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 6) {
            Text(category?.icon ?? "📋")
                .font(.title2)
            
            Text(category?.name ?? "All")
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
        .onTapGesture(perform: onTap)
    }
}

struct FilterOptionCard: View {
    let filter: TaskFilter
    let isSelected: Bool
    let onTap: () -> Void
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            Text(filter.icon)
                .font(.title2)
            
            Text(filter.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
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
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview
struct CategoryManagementView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryManagementView()
            .modelContainer(for: TaskCategory.self, inMemory: true)
    }
}
