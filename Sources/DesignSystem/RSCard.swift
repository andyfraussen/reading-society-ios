import SwiftUI

public struct RSCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(RSSpacing.large)
            .background(RSColor.backgroundElevated)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(RSColor.borderDefault, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
