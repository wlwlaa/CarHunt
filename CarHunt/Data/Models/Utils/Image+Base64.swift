import Foundation
import SwiftUI

extension Image {
    static func fromBase64(
        _ base64: String,
        fallbackSystemName: String = "car.fill"
    ) -> Image {
        let normalizedBase64 = normalized(base64)

        guard
            let data = Data(base64Encoded: normalizedBase64, options: [.ignoreUnknownCharacters]),
            let image = UIImage(data: data)
        else {
            return Image(systemName: fallbackSystemName)
        }

        return Image(uiImage: image)
    }

    private static func normalized(_ base64: String) -> String {
        if base64.starts(with: "data:image"),
           let commaIndex = base64.firstIndex(of: ",") {
            return String(base64[base64.index(after: commaIndex)...])
        }

        return base64
    }
}
