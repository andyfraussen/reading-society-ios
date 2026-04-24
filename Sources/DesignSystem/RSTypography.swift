import SwiftUI

public enum RSTypography {
    public static let display = Font.custom("Cormorant Garamond", size: 56, relativeTo: .largeTitle).weight(.medium)
    public static let h1 = Font.custom("Cormorant Garamond", size: 40, relativeTo: .largeTitle).weight(.medium)
    public static let h2 = Font.custom("Cormorant Garamond", size: 32, relativeTo: .title).weight(.medium)
    public static let h3 = Font.custom("Cormorant Garamond", size: 24, relativeTo: .title2).weight(.semibold)
    public static let bodyLarge = Font.custom("Inter", size: 18, relativeTo: .body)
    public static let body = Font.custom("Inter", size: 16, relativeTo: .body)
    public static let small = Font.custom("Inter", size: 14, relativeTo: .subheadline)
    public static let caption = Font.custom("IBM Plex Mono", size: 12, relativeTo: .caption).weight(.medium)
    public static let control = Font.custom("Inter", size: 13, relativeTo: .callout).weight(.semibold)
}
