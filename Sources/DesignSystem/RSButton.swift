import SwiftUI

public struct RSButton: View {
    public enum Variant {
        case primary
        case secondary
        case ghost
        case destructive
    }

    private let title: String
    private let variant: Variant
    private let action: () -> Void

    public init(_ title: String, variant: Variant = .primary, action: @escaping () -> Void) {
        self.title = title
        self.variant = variant
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(RSTypography.control)
                .tracking(1.04)
                .frame(minHeight: 44)
                .padding(.horizontal, RSSpacing.large)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(RSButtonStyle(variant: variant))
    }
}

public struct RSButtonStyle: ButtonStyle {
    let variant: RSButton.Variant

    public init(variant: RSButton.Variant) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(background.opacity(configuration.isPressed ? 0.82 : 1.0))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch variant {
        case .primary, .destructive:
            RSColor.textInverse
        case .secondary, .ghost:
            RSColor.textPrimary
        }
    }

    private var background: Color {
        switch variant {
        case .primary:
            RSColor.midnight
        case .secondary:
            RSColor.ivory
        case .ghost:
            .clear
        case .destructive:
            RSColor.oxblood
        }
    }

    private var border: Color {
        switch variant {
        case .primary:
            RSColor.midnight
        case .secondary:
            RSColor.borderDefault
        case .ghost:
            .clear
        case .destructive:
            RSColor.oxblood
        }
    }
}
