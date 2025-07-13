//
//  SupplyTemplate.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/12/25.
//

import SwiftData
import Foundation

// MARK: - Supply Template Model
@Model
final class SupplyTemplate {
    var id: UUID
    var name: String
    var quantity: Int
    var estimatedCost: Double?
    var supplier: String?
    var template: TaskTemplate?
    
    init(name: String, quantity: Int = 1, estimatedCost: Double? = nil, supplier: String? = nil) {
        self.id = UUID()
        self.name = name
        self.quantity = max(1, quantity)
        self.estimatedCost = estimatedCost
        self.supplier = supplier
    }
}
