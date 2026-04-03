protocol CardStorage {
    func fetchCards() throws -> [CardDataModel]
    func addCard(_ card: CardDataModel) throws
    func deleteCard(_ card: CardDataModel) throws
}
