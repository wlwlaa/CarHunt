import Foundation
import UIKit

struct CardDTO: Codable {
    let id: UUID
    let uiID: Int
    let imageBase64: String
    let make: String
    let model: String
    let bodyType: BodyType
    let numGrade: Int
    let year: String?
    let power: Int?
    let engineType: String
    let userName: String
    let downVotes: Int
    let notes: String?
    let date: Date
    let longitude: Double?
    let latitude: Double?
}

// MARK: - Mapping
extension CardDTO {
    func toUIModel() -> CardUIModel {
        CardUIModel(
            id: uiID,
            carImage: resolvedImage,
            make: make,
            model: model,
            bodyType: bodyType,
            numGrade: numGrade,
            year: year,
            power: power,
            engineType: engineType,
            userName: userName,
            downVotes: downVotes,
            notes: notes,
            date: date
        )
    }

    func toDataModel(imageCompressionQuality: CGFloat = 0.9) -> CardDataModel {
        let imageData = resolvedImage.jpegData(compressionQuality: imageCompressionQuality)
            ?? resolvedImage.pngData()
            ?? Data()

        return CardDataModel(
            id: id,
            carImage: imageData,
            make: make,
            model: model,
            bodyTypeRaw: bodyType.rawValue,
            numGrade: numGrade,
            year: year,
            power: power,
            engineType: engineType,
            userName: userName,
            downVotes: downVotes,
            notes: notes,
            date: date,
            longitude: longitude,
            latitude: latitude
        )
    }

    private var resolvedImage: UIImage {
        guard
            let data = Data(base64Encoded: normalizedBase64, options: [.ignoreUnknownCharacters]),
            let image = UIImage(data: data)
        else {
            return UIImage(systemName: "car.fill") ?? UIImage()
        }

        return image
    }

    private var normalizedBase64: String {
        if imageBase64.starts(with: "data:image"),
           let commaIndex = imageBase64.firstIndex(of: ",") {
            return String(imageBase64[imageBase64.index(after: commaIndex)...])
        }

        return imageBase64
    }
}

// MARK: - Mock dataset
extension CardDTO {
    static let mockCards: [CardDTO] = [
        CardDTO(
            id: UUID(uuidString: "7A4041A7-6195-4E01-A7E7-0605F9B2D4B1")!,
            uiID: 1,
            imageBase64: MockCardImageBase64.bmw,
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            year: "2022",
            power: 503,
            engineType: "Petrol",
            userName: "andre",
            downVotes: 2,
            notes: "Stock look, clean condition.",
            date: Date(timeIntervalSince1970: 1_726_444_800),
            longitude: 37.6173,
            latitude: 55.7558
        ),
        CardDTO(
            id: UUID(uuidString: "6E769CEE-968A-45CA-82E5-F45DD92C1C1F")!,
            uiID: 2,
            imageBase64: MockCardImageBase64.alfa,
            make: "Alfa Romeo",
            model: "Giulia Quadrifoglio",
            bodyType: .saloon,
            numGrade: 688,
            year: "2021",
            power: 505,
            engineType: "Petrol",
            userName: "maria",
            downVotes: 1,
            notes: "Very aggressive sound.",
            date: Date(timeIntervalSince1970: 1_726_358_400),
            longitude: 30.3141,
            latitude: 59.9386
        ),
        CardDTO(
            id: UUID(uuidString: "B4C7E3A0-2D65-4D8E-9D49-DAD3CA0D196C")!,
            uiID: 3,
            imageBase64: MockCardImageBase64.ford,
            make: "Ford",
            model: "Mustang GT",
            bodyType: .coupe,
            numGrade: 601,
            year: "2019",
            power: 460,
            engineType: "Petrol",
            userName: "ivan",
            downVotes: 4,
            notes: "Classic spec with V8.",
            date: Date(timeIntervalSince1970: 1_726_272_000),
            longitude: 49.1064,
            latitude: 55.7961
        ),
        CardDTO(
            id: UUID(uuidString: "D83B9DA3-B105-49F2-96A1-0B8CA92B34F4")!,
            uiID: 4,
            imageBase64: MockCardImageBase64.lotus,
            make: "Lotus",
            model: "Emira",
            bodyType: .coupe,
            numGrade: 715,
            year: "2023",
            power: 400,
            engineType: "Petrol",
            userName: "artem",
            downVotes: 0,
            notes: "Rare spot near city center.",
            date: Date(timeIntervalSince1970: 1_726_185_600),
            longitude: 39.7015,
            latitude: 47.2357
        ),
        CardDTO(
            id: UUID(uuidString: "1F09C5C6-BD32-43CE-B266-CC9A69E6E3BA")!,
            uiID: 5,
            imageBase64: MockCardImageBase64.porsche,
            make: "Porsche",
            model: "911 Carrera S",
            bodyType: .coupe,
            numGrade: 799,
            year: "2024",
            power: 443,
            engineType: "Petrol",
            userName: "olga",
            downVotes: 1,
            notes: "Perfect paint, no mods.",
            date: Date(timeIntervalSince1970: 1_726_099_200),
            longitude: 82.9346,
            latitude: 55.0084
        ),
        CardDTO(
            id: UUID(uuidString: "02F33F0F-52D4-4F95-B2D6-EDEA741E679D")!,
            uiID: 6,
            imageBase64: MockCardImageBase64.ram,
            make: "RAM",
            model: "1500 TRX",
            bodyType: .allTerrainVehicle,
            numGrade: 645,
            year: "2022",
            power: 702,
            engineType: "Petrol",
            userName: "denis",
            downVotes: 3,
            notes: "Huge build, loud exhaust.",
            date: Date(timeIntervalSince1970: 1_726_012_800),
            longitude: 60.5975,
            latitude: 56.8389
        )
    ]
}
