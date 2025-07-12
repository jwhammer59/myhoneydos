//
//  Supply.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftData
import Foundation

@Model
final class Supply {
    var id: UUID
    var name: String
    var quantity: Int
    var isObtained: Bool
    var task: HoneyDoTask?
    
    init(name: String, quantity: Int = 1, isObtained: Bool = false) {
        self.id = UUID()
        self.name = name
        self.quantity = max(1, quantity) // Ensure quantity is at least 1
        self.isObtained = isObtained
    }
}

