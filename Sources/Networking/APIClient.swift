import Foundation

public protocol TokenProviding: Sendable {
    func token() async -> String?
}

public struct APIClient: Sendable {
    public enum APIError: Error, Equatable {
        case invalidResponse
        case httpStatus(Int)
    }

    private let environment: APIEnvironment
    private let session: URLSession
    private let tokenProvider: (any TokenProviding)?
    private let decoder: JSONDecoder

    public init(
        environment: APIEnvironment = .local,
        session: URLSession = .shared,
        tokenProvider: (any TokenProviding)? = nil
    ) {
        self.environment = environment
        self.session = session
        self.tokenProvider = tokenProvider

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func get<Response: Decodable & Sendable>(
        _ path: String,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        var request = URLRequest(url: environment.baseURL.appending(path: path))
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = await tokenProvider?.token() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpStatus(httpResponse.statusCode)
        }

        return try decoder.decode(Response.self, from: data)
    }
}
