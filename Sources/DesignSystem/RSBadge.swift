import SwiftUI

public struct RSBadge: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text.uppercased())
            .font(RSTypography.caption)
            .tracking(0.96)
            .foregroundStyle(RSColor.textMuted)
            .padding(.horizontal, RSSpacing.xSmall)
            .frame(minHeight: 26)
            .background(RSColor.backgroundSubtle)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(RSColor.borderDefault, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
