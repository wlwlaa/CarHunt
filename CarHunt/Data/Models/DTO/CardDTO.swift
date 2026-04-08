import Foundation
import CryptoKit

struct CardDTO: Codable {
    let id: String
    let imageBase64: String
    let make: String
    let model: String
    let bodyType: BodyType
    let numGrade: Int
    let date: Date
    let year: Int?
    let power: Int?
    let notes: String?
    let longitude: Double?
    let latitude: Double?
}

// MARK: - Mapping
extension CardDTO {
    var uiID: Int {
        if let intID = Int(id) {
            return intID
        }

        return stableHashInt
    }

    func toDataModel() -> CardDataModel {
        return CardDataModel(
            id: stableUUID,
            carImage: normalizedBase64,
            make: make,
            model: model,
            bodyTypeRaw: bodyType.rawValue,
            numGrade: numGrade,
            year: year,
            power: power,
            notes: notes,
            date: date,
            longitude: longitude,
            latitude: latitude
        )
    }

    private var normalizedBase64: String {
        if imageBase64.starts(with: "data:image"),
           let commaIndex = imageBase64.firstIndex(of: ",") {
            return String(imageBase64[imageBase64.index(after: commaIndex)...])
        }

        return imageBase64
    }

    private var stableHashInt: Int {
        let digest = SHA256.hash(data: Data(id.utf8))
        return digest.prefix(4).reduce(0) { ($0 << 8) + Int($1) }
    }

    private var stableUUID: UUID {
        if let uuid = UUID(uuidString: id) {
            return uuid
        }

        let digest = SHA256.hash(data: Data(id.utf8))
        let bytes = Array(digest.prefix(16))

        let tuple: uuid_t = (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        )

        return UUID(uuid: tuple)
    }
}

// MARK: - Mock dataset
extension CardDTO {
    static let mockCards: [CardDTO] = [
        CardDTO(
            id: "1",
            imageBase64: MockCardImageBase64.bmw ?? "",
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            date: Date(timeIntervalSince1970: 1_726_444_800),
            year: 2022,
            power: 503,
            notes: "Stock look, clean condition.",
            longitude: 37.6173,
            latitude: 55.7558
        ),
        CardDTO(
            id: "2",
            imageBase64: MockCardImageBase64.alfa ?? "",
            make: "Alfa Romeo",
            model: "Giulia Quadrifoglio",
            bodyType: .saloon,
            numGrade: 688,
            date: Date(timeIntervalSince1970: 1_726_358_400),
            year: 2021,
            power: 505,
            notes: "Very aggressive sound.",
            longitude: 30.3141,
            latitude: 59.9386
        ),
        CardDTO(
            id: "3",
            imageBase64: MockCardImageBase64.ford ?? "",
            make: "Ford",
            model: "Mustang GT",
            bodyType: .coupe,
            numGrade: 601,
            date: Date(timeIntervalSince1970: 1_726_272_000),
            year: 2019,
            power: 460,
            notes: "Classic spec with V8.",
            longitude: 49.1064,
            latitude: 55.7961
        ),
        CardDTO(
            id: "4",
            imageBase64: MockCardImageBase64.lotus ?? "",
            make: "Lotus",
            model: "Emira",
            bodyType: .coupe,
            numGrade: 715,
            date: Date(timeIntervalSince1970: 1_726_185_600),
            year: 2023,
            power: 400,
            notes: "Rare spot near city center.",
            longitude: 39.7015,
            latitude: 47.2357
        ),
        CardDTO(
            id: "5",
            imageBase64: MockCardImageBase64.porsche ?? "",
            make: "Porsche",
            model: "911 Carrera S",
            bodyType: .coupe,
            numGrade: 799,
            date: Date(timeIntervalSince1970: 1_726_099_200),
            year: 2024,
            power: 443,
            notes: "Perfect paint, no mods.",
            longitude: 82.9346,
            latitude: 55.0084
        ),
        CardDTO(
            id: "6",
            imageBase64: MockCardImageBase64.ram ?? "",
            make: "RAM",
            model: "1500 TRX",
            bodyType: .allTerrainVehicle,
            numGrade: 645,
            date: Date(timeIntervalSince1970: 1_726_012_800),
            year: 2022,
            power: 702,
            notes: "Huge build, loud exhaust.",
            longitude: 60.5975,
            latitude: 56.8389
        )
    ]
}
