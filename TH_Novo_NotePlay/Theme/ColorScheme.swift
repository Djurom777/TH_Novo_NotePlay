//
//  ColorScheme.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct AppColors {
    // Основные цвета из вашей изначальной палитры
    static let mainBackground = Color(hex: "#0A0F2C")      // deep dark blue
    static let secondaryBackground = Color(hex: "#2A0F4C")  // rich purple  
    static let primaryButton = Color(hex: "#E6053A")        // bright red
    static let secondaryButton = Color(hex: "#F5A623")      // golden orange
    static let accent = Color(hex: "#28A809")               // emerald green
    static let primaryText = Color(hex: "#FFFFFF")          // white
    static let secondaryText = Color(hex: "#C0C0C0")        // light gray
    
    // Дополнительные цвета для UI элементов
    static let cardBackground = Color(hex: "#1A1F3C")
    static let divider = Color(hex: "#3A3F5C")
    static let shadow = Color.black.opacity(0.3)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Theme Manager
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true
    
    init() {
        isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
}