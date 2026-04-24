import SwiftUI

public struct RSSecureField: View {
    private let label: String
    private let helper: String?
    @Binding private var text: String

    public init(_ label: String, text: Binding<String>, helper: String? = nil) {
        self.label = label
        self._text = text
        self.helper = helper
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xSmall) {
            Text(label)
                .font(RSTypography.small)
                .foregroundStyle(RSColor.textSecondary)

            SecureField("", text: $text)
                .font(RSTypography.body)
                .foregroundStyle(RSColor.textPrimary)
                .padding(.horizontal, RSSpacing.medium)
                .frame(minHeight: 48)
                .background(RSColor.backgroundElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(RSColor.borderDefault, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))

            if let helper {
                Text(helper)
                    .font(RSTypography.caption)
                    .foregroundStyle(RSColor.textMuted)
            }
        }
    }
}
