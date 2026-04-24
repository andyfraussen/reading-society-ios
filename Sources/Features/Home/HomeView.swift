import DesignSystem
import SwiftUI

public struct HomeView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RSSpacing.large) {
                    VStack(alignment: .leading, spacing: RSSpacing.small) {
                        RSBadge("Private society")

                        Text("The current reading room")
                            .font(RSTypography.h1)
                            .foregroundStyle(RSColor.textPrimary)

                        Text("This placeholder establishes the first screen structure. API backed society, book, notes, and discussion data will replace it in the next phase.")
                            .font(RSTypography.body)
                            .foregroundStyle(RSColor.textSecondary)
                    }

                    RSCard {
                        VStack(alignment: .leading, spacing: RSSpacing.medium) {
                            Text("No active book yet")
                                .font(RSTypography.h3)
                                .foregroundStyle(RSColor.textPrimary)

                            Text("Once connected to `/home`, this card will show the active society book, upcoming discussion, recent notes, and due reading items.")
                                .font(RSTypography.body)
                                .foregroundStyle(RSColor.textSecondary)
                        }
                    }
                }
                .padding(RSSpacing.large)
            }
            .background(RSColor.backgroundDefault)
            .navigationTitle("Home")
        }
    }
}
