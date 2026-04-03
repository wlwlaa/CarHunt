import Foundation

enum CardSortType: Hashable {
    case dateNewest
    case dateOldest
    case yearNewest
    case yearOldest
    case modelAtoZ
    case modelZtoA
    case makeAtoZ
    case makeZtoA
    case powerLowest
    case powerHighest
    case idLowest
    case idHighest
    case downVotesLowest
    case downVotesHighest
    case numgradeLowest
    case numgradeHighest
}

extension CardSortType: CaseIterable {
    static var allCases: [CardSortType] {
        [
            .dateNewest,
            .dateOldest,
            .yearNewest,
            .yearOldest,
            .modelAtoZ,
            .modelZtoA,
            .makeAtoZ,
            .makeZtoA,
            .powerLowest,
            .powerHighest,
            .idLowest,
            .idHighest,
            .downVotesLowest,
            .downVotesHighest,
            .numgradeLowest,
            .numgradeHighest
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
        
        case .modelAtoZ:
            return [SortDescriptor(\.model, order: .forward)]
            
        case .modelZtoA:
            return [SortDescriptor(\.model, order: .reverse)]
            
        case .makeAtoZ:
            return [SortDescriptor(\.make, order: .forward)]
            
        case .makeZtoA:
            return [SortDescriptor(\.make, order: .reverse)]
            
        case .powerLowest:
            return [SortDescriptor(\.power, order: .forward)]
            
        case .powerHighest:
            return [SortDescriptor(\.power, order: .reverse)]
            
        case .idLowest:
            return [SortDescriptor(\.id, order: .forward)]
            
        case .idHighest:
            return [SortDescriptor(\.id, order: .reverse)]
            
        case .downVotesLowest:
            return [SortDescriptor(\.downVotes, order: .forward)]
            
        case .downVotesHighest:
            return [SortDescriptor(\.downVotes, order: .reverse)]
            
        case .numgradeLowest:
            return [SortDescriptor(\.numGrade, order: .forward)]
            
        case .numgradeHighest:
            return [SortDescriptor(\.numGrade, order: .reverse)]
        }
        
    }

    var title: String {
        switch self {
        case .dateNewest:
            return "Date: Newest"
        case .dateOldest:
            return "Date: Oldest"
        case .yearNewest:
            return "Year: Newest"
        case .yearOldest:
            return "Year: Oldest"
        case .modelAtoZ:
            return "Model: A-Z"
        case .modelZtoA:
            return "Model: Z-A"
        case .makeAtoZ:
            return "Make: A-Z"
        case .makeZtoA:
            return "Make: Z-A"
        case .powerLowest:
            return "Power: Lowest"
        case .powerHighest:
            return "Power: Highest"
        case .idLowest:
            return "ID: Lowest"
        case .idHighest:
            return "ID: Highest"
        case .downVotesLowest:
            return "Downvotes: Lowest"
        case .downVotesHighest:
            return "Downvotes: Highest"
        case .numgradeLowest:
            return "Score: Lowest"
        case .numgradeHighest:
            return "Score: Highest"
        }
    }
}
