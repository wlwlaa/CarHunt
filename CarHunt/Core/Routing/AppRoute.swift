import Foundation

enum AppRoute: Hashable, Identifiable {
    case camera
    case cardSettings

    var id: String {
        switch self {
        case .camera:
            return "camera"
        case .cardSettings:
            return "cardSettings"
        }
    }
}
