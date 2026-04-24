import Foundation
import Observation

@MainActor
@Observable
public final class SessionStore {
    public enum State: Equatable {
        case checking
        case signedOut
        case signedIn
    }

    public private(set) var state: State = .checking

    private let tokenStore: AuthTokenStore

    public init(tokenStore: AuthTokenStore = KeychainTokenStore()) {
        self.tokenStore = tokenStore
    }

    public func restore() async {
        state = tokenStore.readToken() == nil ? .signedOut : .signedIn
    }

    public func previewSignIn() {
        tokenStore.saveToken("preview-token")
        state = .signedIn
    }

    public func signOut() {
        tokenStore.deleteToken()
        state = .signedOut
    }
}
