import DesignSystem
import SwiftUI
import Testing

@Test
func designSystemExposesCoreTokens() {
    _ = RSColor.ivory
    _ = RSColor.oxblood
    _ = RSTypography.body
    #expect(RSSpacing.medium == 16)
}
