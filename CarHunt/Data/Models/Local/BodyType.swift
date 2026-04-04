enum BodyType: String, Codable, CaseIterable {
    case saloon = "Saloon"
    case wagon = "Wagon"
    case convertible = "Convertible"
    case minivan = "Minivan"
    case suv = "SUV"
    case allTerrainVehicle = "All-Terrain Vehicle"
    case hatchback3Door = "Hatchback (3-door)"
    case hatchback5Door = "Hatchback (5-door)"
    case coupe = "Coupe"
    case roadster = "Roadster"
    case van = "Van"
    case empty = ""

    var displayName: String {
        rawValue.isEmpty ? "Not selected" : rawValue
    }
}
