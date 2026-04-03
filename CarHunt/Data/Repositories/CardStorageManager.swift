import SwiftData
import Foundation

final class CardStorageManager: CardStorage {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchCards() throws -> [CardDataModel] {
        let descriptor = FetchDescriptor<CardDataModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
    
    func addCard(_ card: CardDataModel) throws {
        context.insert(card)
        try context.save()
    }
    
    func deleteCard(_ card: CardDataModel) throws {
        context.delete(card)
        try context.save()
    }
}
