import SwiftUI
import Combine

@MainActor
final class CardListViewModel: ObservableObject {
    
    @Published var cards: [CardDataModel] = []
    @Published var selectedSortType: CardSortType = .dateNewest
    @Published var isLoadingMockCards = false
    @Published var errorMessage: String?
    
    private let storage: CardStorage
    private let networkService: MockCardsNetworkService
    
    init(storage: CardStorage, networkService: MockCardsNetworkService) {
        self.storage = storage
        self.networkService = networkService
    }
}

// MARK: - repository
extension CardListViewModel {
    func refresh() async {
        loadCards()
    }

    func loadCards(sortType: CardSortType? = nil) {
        if let sortType {
            selectedSortType = sortType
        }

        do {
            cards = try storage.fetchCards(sortType: selectedSortType)
            errorMessage = nil
        } catch {
            errorMessage = "Loading error: \(error.localizedDescription)"
        }
    }
    
    func applySort(_ sortType: CardSortType) {
        loadCards(sortType: sortType)
    }

    func addCard(_ card: CardDataModel) {
        do {
            try storage.addCard(card)
            loadCards()
            errorMessage = nil
        } catch {
            errorMessage = "Saving error: \(error.localizedDescription)"
        }
    }
    
    func deleteCard(_ card: CardDataModel) {
        do {
            try storage.deleteCard(card)
            loadCards()
            errorMessage = nil
        } catch {
            errorMessage = "Delete error: \(error.localizedDescription)"
        }
    }

    func loadMockCardsFromNetwork() async {
        guard !isLoadingMockCards else { return }

        isLoadingMockCards = true
        defer { isLoadingMockCards = false }

        do {
            let existingCards = try storage.fetchCards(sortType: .idLowest)
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
}
