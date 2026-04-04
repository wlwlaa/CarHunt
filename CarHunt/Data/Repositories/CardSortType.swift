import Foundation

enum CardSortType: Hashable {
    case dateNewest
    case dateOldest
    case yearNewest
    case yearOldest
    case makeAtoZ
    case makeZtoA
    case powerLowest
    case powerHighest
    case numgradeHighest
    case numgradeLowest
}

extension CardSortType: CaseIterable {
    static var allCases: [CardSortType] {
        [
            .numgradeHighest,
            .numgradeLowest,
            .dateNewest,
            .dateOldest,
            .yearNewest,
            .yearOldest,
            .makeAtoZ,
            .makeZtoA,
            .powerHighest,
            .powerLowest,
        ]
    }
}

extension CardSortType {
    var sortDescriptors: [SortDescriptor<CardDataModel>] {
        switch self {
        case .dateNewest:
            return [SortDescriptor(\.date, order: .reverse)]
            
        case .dateOldest:
            return [SortDescriptor(\.date, order: .forward)]
            
        case .yearNewest:
            return [SortDescriptor(\.year, order: .reverse)]
            
        case .yearOldest:
            return [SortDescriptor(\.year, order: .forward)]
            
        case .makeAtoZ:
            return [SortDescriptor(\.make, order: .forward)]
            
        case .makeZtoA:
            return [SortDescriptor(\.make, order: .reverse)]
            
        case .powerLowest:
            return [SortDescriptor(\.power, order: .forward)]
            
        case .powerHighest:
            return [SortDescriptor(\.power, order: .reverse)]
            
        case .numgradeLowest:
            return [SortDescriptor(\.numGrade, order: .forward)]
            
        case .numgradeHighest:
            return [SortDescriptor(\.numGrade, order: .reverse)]
        }
        
    }

    var title: String {
        switch self {
        case .numgradeHighest:
            return "Score: Highest"
        case .numgradeLowest:
            return "Score: Lowest"
        case .dateNewest:
            return "Date: Newest"
        case .dateOldest:
            return "Date: Oldest"
        case .yearNewest:
            return "Year: Newest"
        case .yearOldest:
            return "Year: Oldest"
        case .makeAtoZ:
            return "Make: A-Z"
        case .makeZtoA:
            return "Make: Z-A"
        case .powerHighest:
            return "Power: Highest"
        case .powerLowest:
            return "Power: Lowest"
        }
    }
}
