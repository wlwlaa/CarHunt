import SwiftUI

struct CardView: View {
    enum Style {
        case compact
        case expanded
    }

    let card: CardUIModel
    var style: Style = .compact

    private static let captureDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en-US")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            card.carImage
                .resizable()
                .scaledToFill()
                .frame(height: style == .compact ? 120 : 300)
                .frame(maxWidth: style == .compact ? 160 : 350)
                .clipped()
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(card.make)
                            .font(style == .compact ? .caption : .title3)
                            .foregroundStyle(.secondary)

                        Text(card.model)
                            .font(style == .compact ? .headline : .largeTitle.weight(.semibold))
                            .lineLimit(style == .compact ? 1 : 2)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(card.letterGrade)
                            .font(style == .compact ? .headline : .largeTitle.weight(.bold))
                            .fontWeight(.bold)
                            .foregroundStyle(card.gradeAccentColor ?? .primary)

                        Text("\(card.numGrade)")
                            .font(style == .compact ? .caption : .title3)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(card.bodyType.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if let year = card.year {
                    Text("Year: \(year)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("")
                }

                if let power = card.power {
                    Text("Power: \(power) hp")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("")
                }

                if let notes = card.notes, !notes.isEmpty {
                    Text(notes)
                        .font(style == .compact ? .caption : .title3)
                        .lineLimit(style == .compact ? 1 : nil)
                        .foregroundStyle(.primary)
                } else {
                    Text("")
                }
                
                if style == .expanded {
                    Text("Added: \(card.date, formatter: Self.captureDateFormatter)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .shadow(
                    color: (card.gradeAccentColor ?? .clear).opacity(card.gradeShadowOpacity),
                    radius: 8,
                    x: 0,
                    y: 0
                )
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
        .frame(maxWidth: style == .expanded ? .infinity : 180)
    }
}


#Preview("Expanded") {
    CardView(card: CardDTO(
        id: "1",
        imageBase64: MockCardImageBase64.bmw ?? "",
        make: "BMW",
        model: "M4 Competition",
        bodyType: .coupe,
        numGrade: 742,
        date: Date(timeIntervalSince1970: 1_726_444_800),
        year: 2022,
        power: 503,
        notes: "Stock look, clean condition.",
        longitude: 37.6173,
        latitude: 55.7558
    ).toDataModel().asUIModel, style: .expanded
    )
}

#Preview("Many cards") {
    let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

    let cards = [
        CardDTO(
            id: "1",
            imageBase64: MockCardImageBase64.alfa ?? "",
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            date: Date(timeIntervalSince1970: 1_726_444_800),
            year: 2022,
            power: 503,
            notes: "Stock look, clean condition.",
            longitude: 37.6173,
            latitude: 55.7558
        ).toDataModel().asUIModel,
        CardDTO(
            id: "2",
            imageBase64: MockCardImageBase64.porsche ?? "",
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            date: Date(timeIntervalSince1970: 1_726_444_800),
            year: 2022,
            power: 503,
            notes: "Stock look, clean condition.",
            longitude: 37.6173,
            latitude: 55.7558
        ).toDataModel().asUIModel,
        CardDTO(
            id: "3",
            imageBase64: MockCardImageBase64.alfa ?? "",
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            date: Date(timeIntervalSince1970: 1_726_444_800),
            year: 2022,
            power: 503,
            notes: "Stock look, clean condition.",
            longitude: 37.6173,
            latitude: 55.7558
        ).toDataModel().asUIModel,
        CardDTO(
            id: "4",
            imageBase64: MockCardImageBase64.alfa ?? "",
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            date: Date(timeIntervalSince1970: 1_726_444_800),
            year: 2022,
            power: 503,
            notes: "Stock look, clean condition.",
            longitude: 37.6173,
            latitude: 55.7558
        ).toDataModel().asUIModel,
        CardUIModel(id: 5, carImage: Image(systemName: "car"), make: "Nigga", model: "Nigga", bodyType: .convertible, numGrade: 5, date: Date()),
        CardDTO(
            id: "6",
            imageBase64: MockCardImageBase64.bmw ?? "",
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            date: Date(timeIntervalSince1970: 1_726_444_800),
            year: 2022,
            power: 503,
            notes: "Stock look, clean condition.",
            longitude: 37.6173,
            latitude: 55.7558
        ).toDataModel().asUIModel,
        CardDTO(
            id: "7",
            imageBase64: MockCardImageBase64.bmw ?? "",
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            date: Date(timeIntervalSince1970: 1_726_444_800),
            year: 2022,
            power: 503,
            notes: "Stock look, clean condition.",
            longitude: 37.6173,
            latitude: 55.7558
        ).toDataModel().asUIModel,
    ]


    NavigationStack {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(cards, id: \.id) { card in
                    CardView(card: card)
                }
            }
            .padding()
        }
        .navigationTitle("Collection")
    }
        
}
