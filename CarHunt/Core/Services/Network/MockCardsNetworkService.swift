import Foundation

struct MockCardsNetworkService: NetworkService {
    let cardsEndpoint: NetworkEndpoint
    let responseDelayNanoseconds: UInt64

    private let cards: [CardDTO]
    private let encoder: JSONEncoder

    init(
        cards: [CardDTO] = CardDTO.mockCards,
        cardsEndpoint: NetworkEndpoint = .cards,
        responseDelayNanoseconds: UInt64 = 300_000_000,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.cards = cards
        self.cardsEndpoint = cardsEndpoint
        self.responseDelayNanoseconds = responseDelayNanoseconds
        self.encoder = encoder
    }

    func request<T: Decodable>(
        _ endpoint: NetworkEndpoint,
        decoder: JSONDecoder
    ) async throws -> T {
        guard endpoint.key == cardsEndpoint.key else {
            throw NetworkError.missingStub(endpointKey: endpoint.key)
        }

        if responseDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: responseDelayNanoseconds)
        }

        do {
            let data = try encoder.encode(cards)
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingFailed(underlying: decodingError)
        } catch {
            throw NetworkError.custom("MockCardsNetworkService failed: \(error.localizedDescription)")
        }
    }

    func fetchCardsDTO() async throws -> [CardDTO] {
        try await request(cardsEndpoint)
    }

    func fetchCardsUI() async throws -> [CardUIModel] {
        let cardsDTO = try await fetchCardsDTO()
        return cardsDTO.map { $0.toUIModel() }
    }

    func fetchCardsData() async throws -> [CardDataModel] {
        let cardsDTO = try await fetchCardsDTO()
        return cardsDTO.map { $0.toDataModel() }
    }
}

extension NetworkEndpoint {
    static let cards = NetworkEndpoint(path: "/cards", method: .get)
}
