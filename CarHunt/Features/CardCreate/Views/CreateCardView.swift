import SwiftUI

struct CreateCardView: View {
    @StateObject private var viewModel: CreateCardViewModel
    let onSave: (CarDraft) -> Void

    init(
        imageData: Data?,
        onSave: @escaping (CarDraft) -> Void = { _ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: CreateCardViewModel(imageData: imageData)
        )
        self.onSave = onSave
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                imageSection
                formSection

                Button {
                    onSave(viewModel.draft)
                } label: {
                    Text("Save Card")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            viewModel.isSaveEnabled
                            ? Color.white
                            : Color.gray.opacity(0.4)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 18,
                                style: .continuous
                            )
                        )
                }
                .disabled(!viewModel.isSaveEnabled)
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [.black, Color(red: 0.08, green: 0.10, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Create Card")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var imageSection: some View {
        Group {
            if let imageData = viewModel.draft.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.06))

                    Image(systemName: "car.side.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var formSection: some View {
        VStack(spacing: 14) {
            cardTextField(
                title: "Make *",
                text: viewModel.textBinding(for: \.make)
            )

            cardTextField(
                title: "Model *",
                text: viewModel.textBinding(for: \.model)
            )

            bodyTypePicker

            cardTextField(
                title: "Engine Type *",
                text: viewModel.textBinding(for: \.engineType)
            )

            cardTextField(
                title: "Year",
                text: viewModel.textBinding(for: \.year),
                keyboardType: .numberPad
            )

            numericTextField(
                title: "Power",
                text: viewModel.numberBinding(for: \.power)
            )

            numericTextField(
                title: "Grade",
                text: viewModel.numberBinding(for: \.numGrade)
            )

            numericTextField(
                title: "DownVotes",
                text: viewModel.numberBinding(for: \.downVotes)
            )

            cardTextField(
                title: "User Name",
                text: viewModel.textBinding(for: \.userName)
            )

            cardTextField(
                title: "Notes",
                text: viewModel.textBinding(for: \.notes),
                axis: .vertical
            )
        }
    }

    private var bodyTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Body Type *")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))

            Picker("Body Type", selection: viewModel.bodyTypeBinding) {
                ForEach(BodyType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .foregroundStyle(.white)
            .background(Color.white.opacity(0.06))
            .clipShape(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
    }

    private func cardTextField(
        title: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        axis: Axis = .horizontal
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))

            TextField(title, text: text, axis: axis)
                .keyboardType(keyboardType)
                .padding(14)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.06))
                .clipShape(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
    }

    private func numericTextField(
        title: String,
        text: Binding<String>
    ) -> some View {
        cardTextField(
            title: title,
            text: text,
            keyboardType: .numberPad
        )
    }
}

#Preview {
    NavigationStack {
        CreateCardView(imageData: nil)
            .preferredColorScheme(.dark)
    }
}
