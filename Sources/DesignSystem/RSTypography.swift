import SwiftUI

public enum RSTypography {
    public static let display = Font.custom("Cormorant Garamond", size: 56, relativeTo: .largeTitle).weight(.medium)
    public static let h1 = Font.custom("Cormorant Garamond", size: 40, relativeTo: .largeTitle).weight(.medium)
    public static let h2 = Font.custom("Cormorant Garamond", size: 32, relativeTo: .title).weight(.medium)
    public static let h3 = Font.custom("Cormorant Garamond", size: 24, relativeTo: .title2).weight(.semibold)
    public static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    public static let body = Font.system(size: 16, weight: .regular, design: .default)
    public static let small = Font.system(size: 14, weight: .regular, design: .default)
    public static let caption = Font.system(size: 12, weight: .medium, design: .monospaced)
    public static let control = Font.system(size: 13, weight: .semibold, design: .default)
}
