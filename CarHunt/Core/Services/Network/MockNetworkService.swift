import Foundation

actor MockNetworkService: NetworkService {
    private enum Stub {
        case success(Data)
        case failure(Error)
    }

    private var stubs: [String: Stub] = [:]

    func request<T: Decodable>(
        _ endpoint: NetworkEndpoint,
        decoder: JSONDecoder
    ) async throws -> T {
        guard let stub = stubs[endpoint.key] else {
            throw NetworkError.missingStub(endpointKey: endpoint.key)
        }

        switch stub {
        case .failure(let error):
            throw error
        case .success(let data):
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(underlying: error)
            }
        }
    }

    func register<T: Encodable>(
        _ value: T,
        for endpoint: NetworkEndpoint,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        let data = try encoder.encode(value)
        stubs[endpoint.key] = .success(data)
    }

    func register(data: Data, for endpoint: NetworkEndpoint) {
        stubs[endpoint.key] = .success(data)
    }

    func register(error: Error, for endpoint: NetworkEndpoint) {
        stubs[endpoint.key] = .failure(error)
    }
}
