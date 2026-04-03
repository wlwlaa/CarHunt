import Foundation

enum CardSortType {
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
            return [SortDescriptor(\.model, order: .reverse)]
            
        case .modelZtoA:
            return [SortDescriptor(\.model, order: .forward)]
            
        case .makeAtoZ:
            return [SortDescriptor(\.make, order: .reverse)]
            
        case .makeZtoA:
            return [SortDescriptor(\.make, order: .forward)]
            
        case .powerLowest:
            return [SortDescriptor(\.power, order: .reverse)]
            
        case .powerHighest:
            return [SortDescriptor(\.power, order: .forward)]
            
        case .idLowest:
            return [SortDescriptor(\.id, order: .reverse)]
            
        case .idHighest:
            return [SortDescriptor(\.id, order: .forward)]
            
        case .downVotesLowest:
            return [SortDescriptor(\.downVotes, order: .reverse)]
            
        case .downVotesHighest:
            return [SortDescriptor(\.downVotes, order: .forward)]
            
        case .numgradeLowest:
            return [SortDescriptor(\.numGrade, order: .reverse)]
            
        case .numgradeHighest:
            return [SortDescriptor(\.numGrade, order: .forward)]
        }
        
    }
}
