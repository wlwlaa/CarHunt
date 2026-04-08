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

actor URLSessionNetworkService: NetworkService {
    private struct APIErrorResponse: Decodable {
        let error: String?
        let message: String?
    }

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func request<T: Decodable>(
        _ endpoint: NetworkEndpoint,
        decoder: JSONDecoder
    ) async throws -> T {
        let request = try makeRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.custom("Invalid HTTP response.")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let apiError = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.httpError(
                statusCode: httpResponse.statusCode,
                code: apiError?.error,
                message: apiError?.message
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }

    private func makeRequest(for endpoint: NetworkEndpoint) throws -> URLRequest {
        guard let url = makeURL(for: endpoint) else {
            throw NetworkError.invalidURL("\(baseURL.absoluteString)\(endpoint.path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        for (header, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return request
    }

    private func makeURL(for endpoint: NetworkEndpoint) -> URL? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }

        let basePath = components.path
        let endpointPath = endpoint.path.hasPrefix("/") ? endpoint.path : "/\(endpoint.path)"
        components.path = basePath + endpointPath
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        return components.url
    }
}
