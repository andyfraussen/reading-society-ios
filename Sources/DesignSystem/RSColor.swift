import SwiftUI

public enum RSColor {
    public static let ivory = Color(hex: 0xF3EEDF)
    public static let parchment = Color(hex: 0xE4D9C7)
    public static let oxblood = Color(hex: 0x5C2028)
    public static let forestInk = Color(hex: 0x24342E)
    public static let midnight = Color(hex: 0x17191D)
    public static let marbleGray = Color(hex: 0xB8B1A6)
    public static let mutedGold = Color(hex: 0x9C8452)
    public static let dustyPlum = Color(hex: 0x6E5969)

    public static let backgroundDefault = ivory
    public static let backgroundSubtle = parchment
    public static let backgroundElevated = Color(hex: 0xF8F2E5)
    public static let textPrimary = midnight
    public static let textSecondary = Color(hex: 0x4E4A43)
    public static let textMuted = Color(hex: 0x6F695F)
    public static let textInverse = ivory
    public static let accentPrimary = oxblood
    public static let accentSecondary = forestInk
    public static let accentOrnament = mutedGold
    public static let borderDefault = midnight.opacity(0.22)
    public static let borderStrong = midnight.opacity(0.46)
    public static let borderAccent = mutedGold.opacity(0.60)
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}
