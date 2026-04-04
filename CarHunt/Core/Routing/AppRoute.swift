import Foundation

enum AppRoute: Hashable, Identifiable {
    case camera
    case cardSettings
    case collection

    var id: String {
        switch self {
        case .camera:
            return "camera"
        case .cardSettings:
            return "cardSettings"
        case .collection:
            return "collection"
        }
    }
}
