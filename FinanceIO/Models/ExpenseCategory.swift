//
//  ExpenseCategory.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import Foundation
import SwiftData
import SwiftUI

/// A user-defined expense category with an icon and color.
/// Stored via SwiftData so users can add/edit/delete custom categories.
@Model
final class ExpenseCategory {

    // MARK: - Properties

    /// Unique identifier.
    var id: UUID

    /// Display name (e.g., "Food", "Transport").
    var name: String

    /// SF Symbol name for the icon.
    var icon: String

    /// Color stored as a hex string (e.g., "#FF6B35").
    var colorHex: String

    /// Sort order for display (lower = earlier).
    var sortOrder: Int

    /// Whether this is a built-in default category (cannot be deleted).
    var isDefault: Bool

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "tag.fill",
        colorHex: String = "#8E8E93",
        sortOrder: Int = 999,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }

    // MARK: - Color Conversion

    /// Converts the stored hex string to a SwiftUI `Color`.
    var color: Color {
        Color(hex: colorHex)
    }

    // MARK: - Built-in Defaults

    /// Predefined categories seeded on first launch.
    static let builtInDefaults: [(name: String, icon: String, hex: String, order: Int)] = [
        ("Food",          "fork.knife",           "#FF9500", 0),
        ("Transport",     "car.fill",             "#007AFF", 1),
        ("Rent",          "house.fill",           "#AF52DE", 2),
        ("Shopping",      "bag.fill",             "#FF2D55", 3),
        ("Utilities",     "bolt.fill",            "#FFCC00", 4),
        ("Entertainment", "tv.fill",              "#5856D6", 5),
        ("Health",        "heart.fill",           "#FF3B30", 6),
        ("Education",     "book.fill",            "#5AC8FA", 7),
        ("Other",         "ellipsis.circle.fill", "#8E8E93", 8),
    ]
}

// MARK: - Color Hex Extension

extension Color {
    /// Creates a Color from a hex string (e.g. "#FF6B35" or "FF6B35").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0.5; g = 0.5; b = 0.5
        }
        self.init(red: r, green: g, blue: b)
    }
}
