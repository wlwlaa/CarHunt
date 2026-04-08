import Foundation
import SwiftUI
import ImageIO

struct CardUIModel: Identifiable {
    var id: Int
    var carImage: Image
    var photoBase64: String? = nil
    var make: String
    var model: String
    var bodyType: BodyType
    var numGrade: Int
    var year: Int?
    var power: Int?
    var notes: String?
    var date: Date
    var longitude: Double? = nil
    var latitude: Double? = nil
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
        card.photoBase64 = photoData.base64EncodedString()

        let metadata = PhotoMetadataExtractor.extract(from: photoData)
        card.longitude = metadata.longitude
        card.latitude = metadata.latitude
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
        let decodedImageData = Data(
            base64Encoded: carImage.normalizedBase64,
            options: [.ignoreUnknownCharacters]
        )

        return CardUIModel(
            id: abs(id.hashValue),
            carImage: Image.fromBase64(carImage),
            photoBase64: decodedImageData == nil ? nil : carImage.normalizedBase64,
            make: make,
            model: model,
            bodyType: bodyType,
            numGrade: numGrade,
            year: year,
            power: power,
            notes: notes,
            date: date,
            longitude: longitude,
            latitude: latitude
        )
    }
}

extension CardUIModel {
    var asDataModel: CardDataModel {
        CardDataModel(
            id: UUID(),
            carImage: photoBase64 ?? "car.fill",
            make: make.trimmingCharacters(in: .whitespacesAndNewlines),
            model: model.trimmingCharacters(in: .whitespacesAndNewlines),
            bodyTypeRaw: bodyType.rawValue,
            numGrade: numGrade,
            year: year,
            power: power,
            notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            date: date,
            longitude: longitude,
            latitude: latitude
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    var normalizedBase64: String {
        if starts(with: "data:image"),
           let commaIndex = firstIndex(of: ",") {
            return String(self[index(after: commaIndex)...])
        }

        return self
    }
}

private enum PhotoMetadataExtractor {
    struct Metadata {
        let longitude: Double?
        let latitude: Double?
    }

    static func extract(from photoData: Data) -> Metadata {
        guard
            let source = CGImageSourceCreateWithData(photoData as CFData, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
            let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any]
        else {
            return Metadata(longitude: nil, latitude: nil)
        }

        guard
            var latitude = valueAsDouble(gps[kCGImagePropertyGPSLatitude]),
            var longitude = valueAsDouble(gps[kCGImagePropertyGPSLongitude])
        else {
            return Metadata(longitude: nil, latitude: nil)
        }

        if let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
           latitudeRef.uppercased() == "S" {
            latitude = -abs(latitude)
        }

        if let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef] as? String,
           longitudeRef.uppercased() == "W" {
            longitude = -abs(longitude)
        }

        return Metadata(longitude: longitude, latitude: latitude)
    }

    private static func valueAsDouble(_ value: Any?) -> Double? {
        if let number = value as? NSNumber {
            return number.doubleValue
        }

        if let string = value as? String {
            return Double(string)
        }

        return nil
    }
}
