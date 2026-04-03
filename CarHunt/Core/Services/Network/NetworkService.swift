import Foundation

protocol NetworkService {
    func request<T: Decodable>(
        _ endpoint: NetworkEndpoint,
        decoder: JSONDecoder
    ) async throws -> T
}

extension NetworkService {
    func request<T: Decodable>(_ endpoint: NetworkEndpoint) async throws -> T {
        try await request(endpoint, decoder: JSONDecoder())
    }
}

struct NetworkEndpoint: Sendable {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let body: Data?

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}

extension NetworkEndpoint {
    nonisolated var key: String {
        "\(method.rawValue) \(path)"
    }
}

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
