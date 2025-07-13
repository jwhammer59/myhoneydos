//
//  myhoneydosApp.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftUI
import SwiftData

@main
struct HoneyDoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HoneyDoTask.self,
            Supply.self,
            TaskCategory.self,
            TaskTag.self,
            TaskTemplate.self,
            SupplyTemplate.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - App Initialization
    init() {
        // Configure app appearance for bee theme
        configureAppearance()
    }
    
    // MARK: - Private Methods
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(ThemeManager.BeeColors.creamWhite)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(ThemeManager.BeeColors.beeBlack)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(ThemeManager.BeeColors.beeBlack)]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // Configure tab bar appearance for future use
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(ThemeManager.BeeColors.creamWhite)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Configure global tint color
        UIView.appearance().tintColor = UIColor(ThemeManager.BeeColors.honeyYellow)
    }
}
