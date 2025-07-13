//
//  Supply.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/11/25.
//

import SwiftData
import Foundation

// MARK: - Enhanced Supply Model
@Model
final class Supply {
    var id: UUID
    var name: String
    var quantity: Int
    var isObtained: Bool
    var task: HoneyDoTask?
    var estimatedCost: Double?
    var actualCost: Double?
    var supplier: String?
    var notes: String
    
    init(name: String, quantity: Int = 1, isObtained: Bool = false, estimatedCost: Double? = nil, supplier: String? = nil) {
        self.id = UUID()
        self.name = name
        self.quantity = max(1, quantity)
        self.isObtained = isObtained
        self.estimatedCost = estimatedCost
        self.actualCost = nil
        self.supplier = supplier
        self.notes = ""
    }
    
    var totalEstimatedCost: Double {
        guard let cost = estimatedCost else { return 0.0 }
        return cost * Double(quantity)
    }
    
    var totalActualCost: Double {
        guard let cost = actualCost else { return 0.0 }
        return cost * Double(quantity)
    }
}

