import Foundation
import UIKit

struct CarDraft {
    var imageData: Data?

    var make: String = ""
    var model: String = ""
    var bodyType: BodyType = .empty
    var numGrade: String = "0"

    var year: String = ""
    var power: String = ""

    var engineType: String = ""
    var userName: String = "Alexey"
    var downVotes: String = "0"
    var notes: String = ""
}
