enum BodyType: String, Codable {
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
}

extension BodyType: CaseIterable {
    static var allCases: [BodyType] {
        [
            .saloon,
            .wagon,
            .convertible,
            .minivan,
            .suv,
            .allTerrainVehicle,
            .hatchback3Door,
            .hatchback5Door,
            .coupe,
            .roadster,
            .van,
            .empty
        ]
    }
}
