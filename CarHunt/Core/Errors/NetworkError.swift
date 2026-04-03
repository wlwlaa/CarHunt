import Foundation

enum NetworkError: Error {
    case invalidURL(String)
    case decodingFailed(underlying: Error)
    case missingStub(endpointKey: String)
    case custom(String)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .decodingFailed(let underlying):
            return "Decoding failed: \(underlying.localizedDescription)"
        case .missingStub(let endpointKey):
            return "No mock stub for endpoint: \(endpointKey)"
        case .custom(let message):
            return message
        }
    }
}
