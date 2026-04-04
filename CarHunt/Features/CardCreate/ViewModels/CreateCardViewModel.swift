import SwiftUI

final class CreateCardViewModel: ObservableObject {
    @Published var draft: CarDraft

    init(imageData: Data?) {
        self.draft = CarDraft(imageData: imageData)
    }

    var isSaveEnabled: Bool {
        normalized(draft.make) != nil &&
        normalized(draft.model) != nil &&
        draft.bodyType != nil &&
        normalized(draft.engineType) != nil
    }

    func textBinding(
        for keyPath: WritableKeyPath<CarDraft, String?>
    ) -> Binding<String> {
        Binding(
            get: {
                self.draft[keyPath: keyPath] ?? ""
            },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                self.draft[keyPath: keyPath] = trimmed.isEmpty ? nil : newValue
            }
        )
    }

    func numberBinding(
        for keyPath: WritableKeyPath<CarDraft, Int?>
    ) -> Binding<String> {
        Binding(
            get: {
                guard let value = self.draft[keyPath: keyPath] else {
                    return ""
                }
                return String(value)
            },
            set: { newValue in
                let digits = newValue.filter(\.isNumber)
                self.draft[keyPath: keyPath] = digits.isEmpty ? nil : Int(digits)
            }
        )
    }

    var bodyTypeBinding: Binding<BodyType> {
        Binding(
            get: {
                self.draft.bodyType ?? .empty
            },
            set: { newValue in
                self.draft.bodyType = newValue == .empty ? nil : newValue
            }
        )
    }

    private func normalized(_ value: String?) -> String? {
        guard let value else { return nil }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
