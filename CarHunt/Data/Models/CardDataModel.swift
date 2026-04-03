import SwiftData
import Foundation

@Model
class CardDataModel {
    var id: Int
    var carImage: Data
    var make: String
    var model: String
    private var bodyTypeRaw: String
    var numGrade: Int
    var year: String?
    var power: Int?
    var engineType: String
    var userName: String
    var downVotes: Int
    var notes: String?
    var date: Date
    var longitude: Double?
    var latitude: Double?
    
    var bodyType: BodyType {
        get { BodyType(rawValue: bodyTypeRaw) ?? .empty }
        set { bodyTypeRaw = newValue.rawValue }
    }
    
    init(id: Int,
         carImage: Data,
         make: String,
         model: String,
         bodyTypeRaw: String,
         numGrade: Int,
         year: String? = nil,
         power: Int? = nil,
         engineType: String,
         userName: String,
         downVotes: Int,
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
        self.engineType = engineType
        self.userName = userName
        self.downVotes = downVotes
        self.notes = notes
        self.date = date
        self.longitude = longitude
        self.latitude = latitude
    }
}
