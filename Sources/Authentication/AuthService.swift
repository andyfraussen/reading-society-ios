import Foundation
import Networking

public struct AuthService: Sendable {
    private let api: ReadingSocietyAPI
    private let tokenStore: any AuthTokenStore

    public init(api: ReadingSocietyAPI, tokenStore: any AuthTokenStore) {
        self.api = api
        self.tokenStore = tokenStore
    }

    public func register(_ request: RegisterRequest) async throws -> AuthTokenPayload {
        let payload = try await api.register(request)
        tokenStore.saveToken(payload.token)
        return payload
    }

    public func login(_ request: LoginRequest) async throws -> AuthTokenPayload {
        let payload = try await api.login(request)
        tokenStore.saveToken(payload.token)
        return payload
    }

    public func logout() async throws {
        try await api.logout()
        tokenStore.deleteToken()
    }
}
