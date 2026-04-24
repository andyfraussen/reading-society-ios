import Foundation

public protocol TokenProviding: Sendable {
    func token() async -> String?
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct EmptyResponse: Codable, Equatable, Sendable {
    public init() {}
}

public struct APIClient: Sendable {
    public enum APIError: Error, Equatable, Sendable {
        case invalidResponse
        case invalidURL
        case transportStatus(Int, ErrorResponse?)
        case emptyResponse
    }

    private let environment: APIEnvironment
    private let session: URLSession
    private let tokenProvider: (any TokenProviding)?
    private let decoder: JSONDecoder

    public var baseURL: URL {
        environment.baseURL
    }

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
        queryItems: [URLQueryItem] = [],
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        try await request(.get, path, queryItems: queryItems, as: responseType)
    }

    public func post<Body: Encodable & Sendable, Response: Decodable & Sendable>(
        _ path: String,
        body: Body,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        try await request(.post, path, body: body, as: responseType)
    }

    public func post<Response: Decodable & Sendable>(
        _ path: String,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        try await request(.post, path, as: responseType)
    }

    public func patch<Body: Encodable & Sendable, Response: Decodable & Sendable>(
        _ path: String,
        body: Body,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        try await request(.patch, path, body: body, as: responseType)
    }

    public func delete<Response: Decodable & Sendable>(
        _ path: String,
        as responseType: Response.Type = EmptyResponse.self
    ) async throws -> Response {
        try await request(.delete, path, as: responseType)
    }

    public func request<Response: Decodable & Sendable>(
        _ method: HTTPMethod,
        _ path: String,
        queryItems: [URLQueryItem] = [],
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        let request = try await makeRequest(method, path: path, queryItems: queryItems)
        return try await perform(request, as: responseType)
    }

    public func request<Body: Encodable & Sendable, Response: Decodable & Sendable>(
        _ method: HTTPMethod,
        _ path: String,
        queryItems: [URLQueryItem] = [],
        body: Body,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        var request = try await makeRequest(method, path: path, queryItems: queryItems)
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return try await perform(request, as: responseType)
    }

    private func perform<Response: Decodable & Sendable>(
        _ request: URLRequest,
        as responseType: Response.Type
    ) async throws -> Response {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.transportStatus(
                httpResponse.statusCode,
                try? decoder.decode(ErrorResponse.self, from: data)
            )
        }

        guard !data.isEmpty else {
            if let empty = EmptyResponse() as? Response {
                return empty
            }

            throw APIError.emptyResponse
        }

        return try decoder.decode(Response.self, from: data)
    }

    private func makeRequest(
        _ method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> URLRequest {
        guard let url = makeURL(path: path, queryItems: queryItems) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = await tokenProvider?.token() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func makeURL(path: String, queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents(url: environment.baseURL, resolvingAgainstBaseURL: false)
        let basePath = components?.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) ?? ""
        let requestPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        components?.path = "/" + [basePath, requestPath]
            .filter { !$0.isEmpty }
            .joined(separator: "/")
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        return components?.url
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
