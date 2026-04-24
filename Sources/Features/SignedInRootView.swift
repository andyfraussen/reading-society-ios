import Networking
import SwiftUI

public struct SignedInRootView: View {
    private let api: ReadingSocietyAPI
    private let onSignOut: () -> Void

    public init(api: ReadingSocietyAPI, onSignOut: @escaping () -> Void) {
        self.api = api
        self.onSignOut = onSignOut
    }

    public var body: some View {
        TabView {
            HomeView(api: api, onSignOut: onSignOut)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            SocietiesView(api: api)
                .tabItem {
                    Label("Society", systemImage: "person.3")
                }
        }
    }
}
