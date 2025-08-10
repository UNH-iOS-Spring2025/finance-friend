//
//  Theme.swift
//  financefriend
//
//  Created by Nidesh Sri on 09/08/25.
//

import Foundation
import SwiftUI

struct AppTheme {
    static let primary = Color(hex: "#2457CA")
    static let primaryLight = Color(hex: "#4996F2")
    static let background = Color(hex: "#F8F9FB")
    static let cardBackground = Color.white
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
}

extension Color {
    init(hex: String, opacity: Double = 1.0) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
