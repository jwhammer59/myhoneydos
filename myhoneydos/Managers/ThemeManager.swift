//
//  ThemeManager.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftUI

@Observable
class ThemeManager {
    static let shared = ThemeManager()
    
    private init() {}
    
    // MARK: - Bee/Honey Theme Colors
    struct BeeColors {
        static let honeyYellow = Color(red: 1.0, green: 0.84, blue: 0.0)
        static let beeBlack = Color(red: 0.1, green: 0.1, blue: 0.1)
        static let pollenOrange = Color(red: 1.0, green: 0.65, blue: 0.0)
        static let flowerPink = Color(red: 1.0, green: 0.75, blue: 0.8)
        static let leafGreen = Color(red: 0.4, green: 0.8, blue: 0.4)
        static let skyBlue = Color(red: 0.5, green: 0.8, blue: 1.0)
        static let creamWhite = Color(red: 0.98, green: 0.96, blue: 0.9)
    }
    
    // MARK: - Adaptive Colors (Dark/Light Mode)
    var primaryBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    var secondaryBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    var tertiaryBackground: Color {
        Color(UIColor.tertiarySystemBackground)
    }
    
    var primaryText: Color {
        Color(UIColor.label)
    }
    
    var secondaryText: Color {
        Color(UIColor.secondaryLabel)
    }
    
    var accentColor: Color {
        BeeColors.honeyYellow
    }
    
    // MARK: - Priority Colors
    func priorityColor(for priority: Int) -> Color {
        switch priority {
        case 1:
            return BeeColors.leafGreen
        case 2:
            return BeeColors.skyBlue
        case 3:
            return BeeColors.honeyYellow
        case 4:
            return BeeColors.pollenOrange
        case 5:
            return BeeColors.flowerPink
        default:
            return BeeColors.honeyYellow
        }
    }
    
    // MARK: - Status Colors
    func statusColor(for status: TaskStatus) -> Color {
        switch status {
        case .toDo:
            return BeeColors.honeyYellow
        case .inProgress:
            return BeeColors.pollenOrange
        case .completed:
            return BeeColors.leafGreen
        case .onHold:
            return BeeColors.flowerPink
        case .cancelled:
            return BeeColors.beeBlack
        }
    }
    
    // MARK: - Gradient Backgrounds
    var honeyGradient: LinearGradient {
        LinearGradient(
            colors: [BeeColors.honeyYellow, BeeColors.pollenOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var beeGradient: LinearGradient {
        LinearGradient(
            colors: [BeeColors.beeBlack, Color.gray.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
