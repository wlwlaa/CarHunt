import SwiftUI

struct CardView: View {
    enum Style {
        case compact
        case expanded
    }

    let card: CardUIModel
    var style: Style = .compact

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            card.carImage
                .resizable()
                .scaledToFill()
                .frame(height: style == .compact ? 120 : 300)
                .frame(maxWidth: style == .compact ? .infinity : 350)
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
                }

                if let power = card.power {
                    Text("Power: \(power) hp")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(card.engineType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if let notes = card.notes, !notes.isEmpty {
                    Text(notes)
                        .font(style == .compact ? .caption : .title3)
                        .lineLimit(style == .compact ? 2 : nil)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .frame(maxWidth: .infinity)
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
        engineType: "Petrol",
        downVotes: 2,
        date: Date(timeIntervalSince1970: 1_726_444_800),
        year: "2022",
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
        CardUIModel(
            id: 1,
            carImage: Image(systemName: "car.fill"),
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            year: "2022",
            power: 503,
            engineType: "Petrol",
            downVotes: 3,
            notes: "Clean spec, spotted downtown.",
            date: Date()
        ),
        CardUIModel(
            id: 2,
            carImage: Image(systemName: "car.fill"),
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            year: "2022",
            power: 503,
            engineType: "Petrol",
            downVotes: 3,
            notes: "Clean spec, spotted downtown.",
            date: Date()
        ),
        CardUIModel(
            id: 3,
            carImage: Image(systemName: "car.fill"),
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            year: "2022",
            power: 503,
            engineType: "Petrol",
            downVotes: 3,
            notes: "Clean spec, spotted downtown.",
            date: Date()
        ),
        CardUIModel(
            id: 4,
            carImage: Image(systemName: "car.fill"),
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            year: "2022",
            power: 503,
            engineType: "Petrol",
            downVotes: 3,
            notes: "Clean spec, spotted downtown.",
            date: Date()
        ),
        CardUIModel(
            id: 5,
            carImage: Image(systemName: "car.fill"),
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            year: "2022",
            power: 503,
            engineType: "Petrol",
            downVotes: 3,
            notes: "Clean spec, spotted downtown.",
            date: Date()
        ),
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
