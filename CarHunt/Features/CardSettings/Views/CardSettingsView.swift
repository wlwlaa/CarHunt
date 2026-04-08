import SwiftUI

struct CardSettingsView: View {
    @StateObject private var viewModel: CardSettingViewModel

    init(router: any AppRouting, initialCard: CardUIModel = .draft) {
        _viewModel = StateObject(
            wrappedValue: CardSettingViewModel(router: router, initialCard: initialCard)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                viewModel.editableCard.carImage
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .clipped()

                VStack(spacing: 20) {
                    settingsBlock(title: "Characteristics") {
                        TextField("Make", text: card.make)
                        TextField("Model", text: card.model)

                        Picker("Body Type", selection: card.bodyType) {
                            ForEach(BodyType.allCases, id: \.self) { type in
                                Text(type.rawValue.isEmpty ? "Unknown" : type.rawValue)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.menu)

                        TextField("Year", text: yearBinding)
                            .keyboardType(.numberPad)

                        TextField("Power (hp)", text: powerBinding)
                            .keyboardType(.numberPad)
                    }

                    settingsBlock(title: "Rating") {
                        LabeledContent("Grade") {
                            Text("\(viewModel.editableCard.numGrade)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    settingsBlock(title: "Notes") {
                        TextField("Notes", text: notesBinding, axis: .vertical)
                            .lineLimit(3...8)
                    }

                    settingsBlock(title: "Meta") {
                        LabeledContent("Date") {
                            Text(viewModel.editableCard.date.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
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

    @ViewBuilder
    private func settingsBlock<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
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
            get: { viewModel.editableCard.year.map(String.init) ?? "" },
            set: { newValue in
                let normalized = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                viewModel.editableCard.year = Int(normalized)
            }
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
