import SwiftUI

extension Color {
    // MARK: - Warm Classroom Palette
    static let primaryPurple = Color(hex: "#4A6FA5")   // Soft Navy (primary)
    static let deepIndigo = Color(hex: "#2C3E50")      // Dark Slate
    static let softLavender = Color(hex: "#E8E1F0")    // Warm Lavender tint
    static let accentGreen = Color(hex: "#6BBF6A")     // Soft Green
    static let accentOrange = Color(hex: "#F5A623")    // Warm Amber
    static let accentRed = Color(hex: "#E85D5D")       // Soft Red
    static let accentCoral = Color(hex: "#E8765C")     // Coral accent
    static let cardBackground = Color(hex: "#FFFFFF")  // White cards
    static let backgroundGray = Color(hex: "#F7F5F2")  // Warm Cream
    static let darkBackground = Color(hex: "#2C3E50")  // Dark Slate
    static let textPrimary = Color(hex: "#2C3E50")     // Dark Slate text
    static let textSecondary = Color(hex: "#7F8C8D")   // Muted gray text

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
