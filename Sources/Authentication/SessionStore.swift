import Foundation
import Networking
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
    public private(set) var isSubmitting = false
    public private(set) var errorMessage: String?
    public let api: ReadingSocietyAPI

    private let tokenStore: any AuthTokenStore
    private let authService: AuthService

    public init(
        tokenStore: any AuthTokenStore = KeychainTokenStore(),
        api: ReadingSocietyAPI? = nil,
        authService: AuthService? = nil
    ) {
        self.tokenStore = tokenStore

        let client = APIClient(tokenProvider: tokenStore)
        self.api = api ?? ReadingSocietyAPI(client: client)
        self.authService = authService ?? AuthService(api: self.api, tokenStore: tokenStore)
    }

    public func restore() async {
        state = tokenStore.readToken() == nil ? .signedOut : .signedIn
    }

    public func login(email: String, password: String) async {
        await submit {
            _ = try await authService.login(
                LoginRequest(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    deviceName: deviceName
                )
            )
        }
    }

    public func register(name: String, email: String, password: String) async {
        await submit {
            _ = try await authService.register(
                RegisterRequest(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    deviceName: deviceName,
                    timezone: TimeZone.current.identifier,
                    locale: Locale.current.identifier
                )
            )
        }
    }

    public func clearError() {
        errorMessage = nil
    }

    public func signOut() {
        tokenStore.deleteToken()
        state = .signedOut
    }

    public func logout() async {
        do {
            try await authService.logout()
        } catch {
            tokenStore.deleteToken()
        }

        state = .signedOut
    }

    private func submit(_ action: () async throws -> Void) async {
        guard !isSubmitting else {
            return
        }

        isSubmitting = true
        errorMessage = nil

        do {
            try await action()
            state = .signedIn
        } catch {
            errorMessage = Self.message(for: error)
        }

        isSubmitting = false
    }

    private static func message(for error: Error) -> String {
        if let apiError = error as? APIClient.APIError {
            switch apiError {
            case let .transportStatus(_, response):
                if let validationMessage = response?.errors?.values.first?.first {
                    return validationMessage
                }

                if let message = response?.message, !message.isEmpty {
                    return message
                }

                return "The server rejected this request."
            case .invalidURL:
                return "The API address is invalid."
            case .invalidResponse:
                return "The server returned an invalid response."
            case .emptyResponse:
                return "The server returned an empty response."
            }
        }

        return error.localizedDescription
    }

    private var deviceName: String {
        "Reading Society iOS"
    }
}
