protocol CardStorage {
    func fetchCards(sortType: CardSortType) throws -> [CardDataModel]
    func addCard(_ card: CardDataModel) throws
    func deleteCard(_ card: CardDataModel) throws
}
