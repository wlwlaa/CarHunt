import SwiftUI

struct CardSettingsView: View {
    @StateObject private var viewModel: CardSettingViewModel

    init(router: any AppRouting) {
        _viewModel = StateObject(wrappedValue: CardSettingViewModel(router: router))
    }

    var body: some View {
        Form {
            Section("Preview") {
                viewModel.editableCard.carImage
                //CardView(card: viewModel.editableCard)
            }

            Section("Characteristics") {
                TextField("Make", text: card.make)
                TextField("Model", text: card.model)

                Picker("Body Type", selection: card.bodyType) {
                    ForEach(BodyType.allCases, id: \.self) { type in
                        Text(type.rawValue.isEmpty ? "Unknown" : type.rawValue)
                            .tag(type)
                    }
                }

                TextField("Engine Type", text: card.engineType)

                TextField("Year", text: yearBinding)
                    .keyboardType(.numberPad)

                TextField("Power (hp)", text: powerBinding)
                    .keyboardType(.numberPad)
            }

            Section("Rating") {
                Stepper("Grade: \(viewModel.editableCard.numGrade)", value: card.numGrade, in: 0...1000)
                Stepper("DownVotes: \(viewModel.editableCard.downVotes)", value: card.downVotes, in: 0...1000)
            }

            Section("Notes") {
                TextField("Notes", text: notesBinding, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section("Meta") {
                DatePicker(
                    "Date",
                    selection: card.date,
                    displayedComponents: [.date, .hourAndMinute]
                )

                Text("Card id: \(viewModel.editableCard.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Image is preview-only in this draft screen")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Card Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Collection") {
                    viewModel.openCollection()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Discard") {
                    viewModel.openCamera()
                }
                .tint(.red)
            }
        }
    }

    private var card: Binding<CardUIModel> {
        Binding(
            get: { viewModel.editableCard },
            set: { viewModel.editableCard = $0 }
        )
    }

    private var notesBinding: Binding<String> {
        Binding(
            get: { viewModel.editableCard.notes ?? "" },
            set: { viewModel.editableCard.notes = $0.isEmpty ? nil : $0 }
        )
    }

    private var yearBinding: Binding<String> {
        Binding(
            get: { viewModel.editableCard.year ?? "" },
            set: { viewModel.editableCard.year = $0.isEmpty ? nil : $0 }
        )
    }

    private var powerBinding: Binding<String> {
        Binding(
            get: { viewModel.editableCard.power.map(String.init) ?? "" },
            set: { newValue in
                let normalized = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                viewModel.editableCard.power = Int(normalized)
            }
        )
    }
}

#Preview {
    NavigationStack {
        CardSettingsView(router: AppRouter())
    }
}
