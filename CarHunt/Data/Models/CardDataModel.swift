import SwiftData
import Foundation

@Model
class CardDataModel {
    var id: Int
    var carImage: Data
    var make: String
    var model: String
    var bodyType: BodyType
    var numGrade: Int
    var year: String?
    var power: Int?
    var engineType: String
    var userName: String
    var downVotes: Int
    var notes: String?
    var date: Date
    var longitude: Double?
    var lontitude: Double?
    
    init(id: Int,
         make: String,
         model: String,
         bodyType: BodyType,
         numGrade: Int,
         year: String? = nil,
         power: Int? = nil,
         engineType: String,
         userName: String,
         downVotes: Int,
         notes: String? = nil,
         date: Date,
         longitude: Double? = nil,
         lontitude: Double? = nil) {
        self.id = id
        self.make = make
        self.model = model
        self.bodyType = bodyType
        self.numGrade = numGrade
        self.year = year
        self.power = power
        self.engineType = engineType
        self.userName = userName
        self.downVotes = downVotes
        self.notes = notes
        self.date = date
        self.longitude = longitude
        self.lontitude = lontitude
    }
}
