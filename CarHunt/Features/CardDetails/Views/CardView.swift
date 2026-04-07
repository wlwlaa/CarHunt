import SwiftUI

struct CardView: View {
    let card: CardUIModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            card.carImage
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(card.make)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(card.model)
                            .font(.headline)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(card.letterGrade)
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("\(card.numGrade)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text("\(String(describing: card.bodyType))")
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

                if let notes = card.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .lineLimit(2)
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

#Preview {
    CardView(
        card: CardUIModel(
            id: 1,
            carImage: Image(systemName: "car.fill"),
            make: "BMW",
            model: "M4 Competition",
            bodyType: .coupe,
            numGrade: 742,
            year: "2022",
            power: 503,
            downVotes: 3,
            notes: "Clean spec, spotted downtown.",
            date: Date()
        )
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
            downVotes: 3,
            notes: "Clean spec, spotted downtown.",
            date: Date()
        )
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
