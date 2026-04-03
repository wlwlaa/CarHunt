import SwiftUI
import Combine

final class CardListViewModel: ObservableObject {
    
    @Published var cards: [CardDataModel] = []
    
    private let storage: CardStorage
    
    init(storage: CardStorage) {
        self.storage = storage
    }
}

// MARK: - repository
extension CardListViewModel {
    func loadCards(sortType: CardSortType = .dateNewest) {
        do {
            cards = try storage.fetchCards(sortType: sortType)
        } catch {
            print("loading error: \(error)")
        }
    }
    
    func addCard(_ card: CardDataModel) {
        do {
            try storage.addCard(card)
            loadCards()
        } catch {
            print("pulling error: \(error)")
        }
    }
    
    func deleteCard(_ card: CardDataModel) {
        do {
            try storage.deleteCard(card)
            loadCards()
        } catch {
            print("deleting error: \(error)")
        }
    }
}
