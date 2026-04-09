import Foundation

enum AppRoute: Hashable, Identifiable {
    case camera
    case map
    case cardSettings
    case collection

    var id: String {
        switch self {
        case .camera:
            return "camera"
        case .map:
            return "map"
        case .cardSettings:
            return "cardSettings"
        case .collection:
            return "collection"
        }
    }
}
