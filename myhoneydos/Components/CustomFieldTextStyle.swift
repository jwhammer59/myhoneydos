//
//  CustomFieldTextStyle.swift
//  myhoneydos
//
//  Created by Jeffery Hammer on 7/13/25.
//

import SwiftUI

// MARK: - Custom Text Field Style (if not already defined elsewhere)
struct CustomTextFieldStyle: TextFieldStyle {
    private let themeManager = ThemeManager.shared
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(themeManager.tertiaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
            )
    }
}
