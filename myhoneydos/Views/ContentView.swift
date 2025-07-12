//
//  ContentView.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var tasks: [HoneyDoTask]
    
    @State private var showingAddTask = false
    @State private var selectedTask: HoneyDoTask?
    @State private var filterStatus: TaskStatus?
    @State private var sortOption: SortOption = .dateCreated
    
    private let themeManager = ThemeManager.shared
    private let dataManager = DataManager.shared
    
    enum SortOption: String, CaseIterable {
        case dateCreated = "Date Created"
        case priority = "Priority"
        case status = "Status"
        case title = "Title"
    }
    
    var filteredTasks: [HoneyDoTask] {
        var result = tasks
        
        // Apply status filter
        if let filterStatus = filterStatus {
            result = result.filter { $0.status == filterStatus }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateCreated:
            result = result.sorted { $0.createdDate > $1.createdDate }
        case .priority:
            result = result.sorted { $0.priority > $1.priority }
        case .status:
            result = result.sorted { $0.status.rawValue < $1.status.rawValue }
        case .title:
            result = result.sorted { $0.title < $1.title }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with floating bee
                    headerView
                    
                    // Filter and Sort Controls
                    controlsView
                    
                    // Task List
                    taskListView
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Animated Bee
                Text("🐝")
                    .font(.largeTitle)
                    .floating()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Honey Do's")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Sweet tasks await! 🍯")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                // Add Task Button
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.accentColor)
                }
                .scaleEffect(showingAddTask ? 1.2 : 1.0)
                .animation(AnimationManager.cardPress, value: showingAddTask)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Stats Row
            HStack(spacing: 20) {
                StatCard(title: "Total", count: tasks.count, icon: "🍯")
                StatCard(title: "To Do", count: tasks.filter { $0.status == .toDo }.count, icon: "🐝")
                StatCard(title: "Done", count: tasks.filter { $0.status == .completed }.count, icon: "✅")
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.secondaryBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var controlsView: some View {
        HStack(spacing: 16) {
            // Filter Menu
            Menu {
                Button("All Tasks") { filterStatus = nil }
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Button("\(status.icon) \(status.rawValue)") {
                        filterStatus = status
                    }
                }
            } label: {
                HStack {
                    Text(filterStatus?.rawValue ?? "All Tasks")
                        .font(.subheadline)
                        .foregroundColor(themeManager.primaryText)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(themeManager.tertiaryBackground)
                .cornerRadius(8)
            }
            
            // Sort Menu
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(option.rawValue) {
                        sortOption = option
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.caption)
                    Text(sortOption.rawValue)
                        .font(.subheadline)
                        .foregroundColor(themeManager.primaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(themeManager.tertiaryBackground)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredTasks) { task in
                    TaskCardView(task: task) {
                        selectedTask = task
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
        .animation(AnimationManager.listItemSlide, value: filteredTasks.count)
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title2)
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryText)
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(themeManager.tertiaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: HoneyDoTask.self, inMemory: true)
    }
}
