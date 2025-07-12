//
//  AnimationManager.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftUI

struct AnimationManager {
    
    // MARK: - Heart Priority Animations
    static func heartBeat(for priority: Int) -> Animation {
        let intensity = Double(priority) / 5.0
        return Animation
            .easeInOut(duration: 0.6 + intensity * 0.4)
            .repeatCount(3, autoreverses: true)
    }
    
    static func heartScale(for priority: Int) -> Double {
        1.0 + (Double(priority) * 0.1)
    }
    
    // MARK: - Task Completion Animations
    static let taskComplete = Animation.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.5)
    
    static let taskBounce = Animation.interpolatingSpring(stiffness: 300, damping: 10)
    
    // MARK: - Bee Flying Animation
    static let beeFloat = Animation
        .easeInOut(duration: 2.0)
        .repeatForever(autoreverses: true)
    
    static let beeWiggle = Animation
        .easeInOut(duration: 0.5)
        .repeatCount(3, autoreverses: true)
    
    // MARK: - Honey Drip Animation
    static let honeyDrip = Animation
        .easeIn(duration: 1.5)
        .delay(0.2)
    
    // MARK: - Card Animations
    static let cardAppear = Animation
        .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3)
    
    static let cardPress = Animation
        .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.2)
    
    // MARK: - List Animations
    static let listItemSlide = Animation
        .spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.4)
    
    static let listItemDelete = Animation
        .easeInOut(duration: 0.4)
    
    // MARK: - Supply Animations
    static let supplyCheck = Animation
        .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.3)
    
    static let supplyAdd = Animation
        .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.4)
}

// MARK: - Custom Animation Modifiers
struct BeeWiggleModifier: ViewModifier {
    @State private var isWiggling = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isWiggling ? 5 : -5))
            .animation(AnimationManager.beeWiggle, value: isWiggling)
            .onAppear {
                isWiggling = true
            }
    }
}

struct HeartBeatModifier: ViewModifier {
    let priority: Int
    @State private var isBeating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBeating ? AnimationManager.heartScale(for: priority) : 1.0)
            .animation(AnimationManager.heartBeat(for: priority), value: isBeating)
            .onAppear {
                isBeating = true
            }
    }
}

struct FloatingModifier: ViewModifier {
    @State private var isFloating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -10 : 10)
            .animation(AnimationManager.beeFloat, value: isFloating)
            .onAppear {
                isFloating = true
            }
    }
}

// MARK: - View Extensions
extension View {
    func beeWiggle() -> some View {
        self.modifier(BeeWiggleModifier())
    }
    
    func heartBeat(priority: Int) -> some View {
        self.modifier(HeartBeatModifier(priority: priority))
    }
    
    func floating() -> some View {
        self.modifier(FloatingModifier())
    }
}
