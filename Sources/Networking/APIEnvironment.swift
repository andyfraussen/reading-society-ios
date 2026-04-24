import Foundation

public struct APIEnvironment: Equatable, Sendable {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public static let local = APIEnvironment(
        baseURL: URL(string: "https://reading-society-api.ddev.site")!
    )
}
