import Foundation
import SwiftUI

struct CardUIModel: Identifiable {
    let id: Int
    let carImage: Image
    let make: String
    let model: String
    let bodyType: BodyType
    let numGrade: Int
    let year: String?
    let power: Int?
    let userName: String
    let downVotes: Int
    let notes: String?
    let date: Date
}

extension CardUIModel {
    var letterGrade: String {
        switch numGrade {
        case 0...100:
            return "F"
        case 100..<200:
            return "E"
        case 200..<300:
            return "D"
        case 300..<400:
            return "C"
        case 400..<500:
            return "B"
        case 500..<600:
            return "A"
        case 600..<700:
            return "A+"
        case 700..<800:
            return "S"
        case 800..<900:
            return "S+"
        case 900...:
            return "X"
        default:
            return "N/A"
        }
    }
}

extension CardDataModel {
    var asUIModel: CardUIModel {
        CardUIModel(
            id: abs(id.hashValue),
            carImage: Image.fromBase64(carImage),
            make: make,
            model: model,
            bodyType: bodyType,
            numGrade: numGrade,
            year: year,
            power: power,
            userName: "",
            downVotes: downVotes,
            notes: notes,
            date: date
        )
    }
}
