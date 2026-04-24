import Authentication
import DesignSystem
import Features
import SwiftUI

public struct AppRootView: View {
    @State private var sessionStore = SessionStore()

    public init() {}

    public var body: some View {
        Group {
            switch sessionStore.state {
            case .checking:
                LaunchView()
            case .signedOut:
                SignedOutView {
                    sessionStore.previewSignIn()
                }
            case .signedIn:
                HomeView()
            }
        }
        .background(RSColor.backgroundDefault.ignoresSafeArea())
        .task {
            await sessionStore.restore()
        }
    }
}

private struct LaunchView: View {
    var body: some View {
        VStack(spacing: RSSpacing.large) {
            Text("Reading Society")
                .font(RSTypography.display)
                .foregroundStyle(RSColor.textPrimary)

            ProgressView()
                .tint(RSColor.accentPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SignedOutView: View {
    let onPreviewSignIn: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RSSpacing.xLarge) {
            VStack(alignment: .leading, spacing: RSSpacing.medium) {
                Text("Reading Society")
                    .font(RSTypography.display)
                    .foregroundStyle(RSColor.textPrimary)

                Text("A private room for shared reading, marginalia, discussion, and the slow record of a book in progress.")
                    .font(RSTypography.bodyLarge)
                    .foregroundStyle(RSColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RSButton("Enter preview", variant: .primary, action: onPreviewSignIn)
        }
        .padding(RSSpacing.xxLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
