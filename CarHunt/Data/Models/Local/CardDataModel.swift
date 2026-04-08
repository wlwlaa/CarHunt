import SwiftData
import Foundation

@Model
class CardDataModel {
    var id: UUID
    var carImage: String
    var make: String
    var model: String
    private var bodyTypeRaw: String
    var numGrade: Int
    var year: Int?
    var power: Int?
    var notes: String?
    var date: Date
    var longitude: Double?
    var latitude: Double?
    
    var bodyType: BodyType {
        get { BodyType(rawValue: bodyTypeRaw) ?? .empty }
        set { bodyTypeRaw = newValue.rawValue }
    }
    
    init(id: UUID,
         carImage: String,
         make: String,
         model: String,
         bodyTypeRaw: String,
         numGrade: Int,
         year: Int? = nil,
         power: Int? = nil,
         notes: String? = nil,
         date: Date,
         longitude: Double? = nil,
         latitude: Double? = nil) {
        self.id = id
        self.carImage = carImage
        self.make = make
        self.model = model
        self.bodyTypeRaw = bodyTypeRaw
        self.numGrade = numGrade
        self.year = year
        self.power = power
        self.notes = notes
        self.date = date
        self.longitude = longitude
        self.latitude = latitude
    }
}
