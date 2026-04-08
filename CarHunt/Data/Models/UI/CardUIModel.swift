import Foundation
import SwiftUI

struct CardUIModel: Identifiable {
    var id: Int
    var carImage: Image
    var make: String
    var model: String
    var bodyType: BodyType
    var numGrade: Int
    var year: Int?
    var power: Int?
    var notes: String?
    var date: Date
}

extension CardUIModel {
    static var draft: CardUIModel {
        CardUIModel(
            id: 0,
            carImage: Image(systemName: "car"),
            make: "",
            model: "",
            bodyType: .empty,
            numGrade: 0,
            year: nil,
            power: nil,
            notes: nil,
            date: Date()
        )
    }

    static func draft(withPhotoData photoData: Data) -> CardUIModel {
        var card = Self.draft
        card.carImage = Image.fromData(photoData)
        return card
    }

    var gradeAccentColor: Color? {
        switch numGrade {
        case 0...100:
            return nil
        case 100..<200:
            return .gray
        case 200..<300:
            return .white
        case 300..<400:
            return Color(red: 0.71, green: 0.93, blue: 0.78)
        case 400..<500:
            return .cyan
        case 500..<600:
            return .blue
        case 600..<700:
            return .purple
        case 700..<800:
            return .pink
        case 800..<900:
            return .red
        case 900...:
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        default:
            return nil
        }
    }

    var gradeShadowOpacity: Double {
        switch numGrade {
        case 0...100:
            return 0
        case 200..<300:
            return 0.9
        default:
            return 0.6
        }
    }

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
    // Decode base64 only at UI mapping boundary.
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
            notes: notes,
            date: date
        )
    }
}

extension CardUIModel {
    var asDataModel: CardDataModel {
        CardDataModel(
            id: UUID(),
            carImage: "car.fill",
            make: make.trimmingCharacters(in: .whitespacesAndNewlines),
            model: model.trimmingCharacters(in: .whitespacesAndNewlines),
            bodyTypeRaw: bodyType.rawValue,
            numGrade: numGrade,
            year: year,
            power: power,
            notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            date: date,
            longitude: nil,
            latitude: nil
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
