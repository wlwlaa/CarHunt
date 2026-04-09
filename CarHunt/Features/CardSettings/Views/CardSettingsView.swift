import SwiftUI

struct CardSettingsView: View {
    @StateObject private var viewModel: CardSettingViewModel
    @State private var flashingFields: Set<CardSettingViewModel.RequiredField> = []
    @State private var flashTask: Task<Void, Never>?

    init(
        router: any AppRouting,
        storage: CardStorage,
        initialCard: CardUIModel = .draft,
        initialDataModel: CardDataModel? = nil,
        initialPhotoData: Data? = nil,
        cardAutofillService: CardAutofillServicing? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: CardSettingViewModel(
                router: router,
                storage: storage,
                initialCard: initialCard,
                initialDataModel: initialDataModel,
                initialPhotoData: initialPhotoData,
                cardAutofillService: cardAutofillService
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                viewModel.editableCard.carImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 334)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color(.separator).opacity(0.18), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 18)

                Button("Autofill") {
                    Task {
                        await viewModel.applyAutofillIfNeeded()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.top, 16)
                .disabled(viewModel.isAutofillInProgress)

                if viewModel.isAutofillInProgress {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Recognizing car details...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 16)
                }

                VStack(spacing: 20) {
                    settingsBlock(title: "Characteristics") {
                        fieldContainer(for: .make) {
                            TextField("Make", text: card.make)
                                .textFieldStyle(.plain)
                        }

                        fieldContainer(for: .model) {
                            TextField("Model", text: card.model)
                                .textFieldStyle(.plain)
                        }

                        fieldContainer(for: .bodyType) {
                            Picker("Body Type", selection: card.bodyType) {
                                ForEach(BodyType.allCases, id: \.self) { type in
                                    Text(type.rawValue.isEmpty ? "Unknown" : type.rawValue)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }

                        regularFieldContainer {
                            TextField("Year", text: yearBinding)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                        }

                        regularFieldContainer {
                            TextField("Power (hp)", text: powerBinding)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                        }
                    }

                    settingsBlock(title: "Rating") {
                        LabeledContent("Grade") {
                            Text("\(viewModel.editableCard.numGrade)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    settingsBlock(title: "Notes") {
                        regularFieldContainer {
                            TextField("Notes", text: notesBinding, axis: .vertical)
                                .lineLimit(3...8)
                                .textFieldStyle(.plain)
                        }
                    }

                    settingsBlock(title: "Meta") {
                        LabeledContent("Date") {
                            Text(viewModel.editableCard.date.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(viewModel.isAutofillInProgress)
                .padding(20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.validationFlashTrigger) { _ in
            flashTask?.cancel()
            flashTask = Task {
                await flashInvalidFields(viewModel.invalidFieldsForFlash)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    viewModel.addCard()
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

    @ViewBuilder
    private func fieldContainer<Content: View>(
        for field: CardSettingViewModel.RequiredField,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fieldBackgroundColor(for: field))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(fieldBorderColor(for: field), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private func regularFieldContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.separator).opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func fieldBackgroundColor(for field: CardSettingViewModel.RequiredField) -> Color {
        flashingFields.contains(field) ? Color.red.opacity(0.18) : Color(.systemBackground)
    }

    private func fieldBorderColor(for field: CardSettingViewModel.RequiredField) -> Color {
        flashingFields.contains(field) ? .red : Color(.separator).opacity(0.2)
    }

    @MainActor
    private func flashInvalidFields(_ fields: Set<CardSettingViewModel.RequiredField>) async {
        guard !fields.isEmpty else { return }

        for _ in 0..<2 {
            withAnimation(.easeInOut(duration: 0.11)) {
                flashingFields.formUnion(fields)
            }
            try? await Task.sleep(nanoseconds: 120_000_000)

            withAnimation(.easeInOut(duration: 0.11)) {
                flashingFields.subtract(fields)
            }
            try? await Task.sleep(nanoseconds: 120_000_000)
        }
    }
}

#Preview {
    NavigationStack {
        CardSettingsView(
            router: AppRouter(),
            storage: PreviewCardStorage()
        )
    }
}

private final class PreviewCardStorage: CardStorage {
    func fetchCards(sortType: CardSortType) throws -> [CardDataModel] {
        []
    }

    func addCard(_ card: CardDataModel) throws {}

    func deleteCard(_ card: CardDataModel) throws {}
}
