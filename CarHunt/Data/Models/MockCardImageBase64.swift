import Foundation


enum MockCardImageBase64 {
    static let bmw = load(named: "bmw")
    static let alfa = load(named: "alfa")
    static let ford = load(named: "ford")
    static let lotus = load(named: "lotus")
    static let porsche = load(named: "porsche")
    static let ram = load(named: "ram")

    private static func load(named resourceName: String) -> String? {
        let url =
            Bundle.main.url(forResource: resourceName, withExtension: "base64", subdirectory: "MockBase64")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "base64", subdirectory: "Resources/MockBase64")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "base64")

        guard let url else {
            assertionFailure("Missing base64 resource: \(resourceName).base64")
            return nil
        }

        do {
            let value = try String(contentsOf: url, encoding: .utf8)
            return value.components(separatedBy: .whitespacesAndNewlines).joined()
        } catch {
            assertionFailure("Failed to read base64 resource \(resourceName): \(error)")
            return nil
        }
    }
}
