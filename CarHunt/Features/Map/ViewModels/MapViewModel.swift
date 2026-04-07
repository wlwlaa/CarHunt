import SwiftUI
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published var cards: [CardDTO] = []
    @Published var isLoadingMockCards = false
    @Published var errorMessage: String?

    private let storage: CardStorage
    private let networkService: MockCardsNetworkService

    init(storage: CardStorage, networkService: MockCardsNetworkService) {
        self.storage = storage
        self.networkService = networkService
    }

    var cardsWithLocations: [CardDTO] {
        cards.filter { $0.latitude != nil && $0.longitude != nil }
    }
}

extension MapViewModel {
    func loadCards() {
        do {
            let storedCards = try storage.fetchCards(sortType: .dateNewest)
            cards = storedCards.map { makeCardDTO(from: $0) }
            errorMessage = nil
        } catch {
            errorMessage = "Loading error: \(error.localizedDescription)"
        }
    }

    func refresh() async {
        loadCards()
    }

    func loadMockCardsFromNetwork() async {
        guard !isLoadingMockCards else { return }

        isLoadingMockCards = true
        defer { isLoadingMockCards = false }

        do {
            let existingCards = try storage.fetchCards(sortType: .dateNewest)
            var existingIDs = Set(existingCards.map(\.id))

            let remoteCards = try await networkService.fetchCardsData()
            for remoteCard in remoteCards where !existingIDs.contains(remoteCard.id) {
                try storage.addCard(remoteCard)
                existingIDs.insert(remoteCard.id)
            }

            loadCards()
            errorMessage = nil
        } catch {
            errorMessage = "Mock loading error: \(error.localizedDescription)"
        }
    }

    private func makeCardDTO(from card: CardDataModel) -> CardDTO {
        CardDTO(
            id: card.id.uuidString,
            imageBase64: card.carImage,
            make: card.make,
            model: card.model,
            bodyType: card.bodyType,
            numGrade: card.numGrade,
            engineType: card.engineType,
            downVotes: card.downVotes,
            date: card.date,
            year: card.year,
            power: card.power,
            notes: card.notes,
            longitude: card.longitude,
            latitude: card.latitude
        )
    }
}
