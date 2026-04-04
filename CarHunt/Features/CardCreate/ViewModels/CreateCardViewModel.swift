import Foundation
import Combine
import UIKit

final class CreateCardViewModel: ObservableObject {
    @Published var draft: CarDraft

    init(imageData: Data?) {
        self.draft = CarDraft(imageData: imageData)
    }

    var isSaveEnabled: Bool {
        !draft.make.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !draft.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        draft.bodyType != .empty &&
        !draft.engineType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func updateYear(_ value: String) {
        draft.year = value.filter(\.isNumber)
    }

    func updatePower(_ value: String) {
        draft.power = value.filter(\.isNumber)
    }

    func updateGrade(_ value: String) {
        draft.numGrade = value.filter(\.isNumber)
    }

    func updateDownVotes(_ value: String) {
        draft.downVotes = value.filter(\.isNumber)
    }

    func buildCard() -> CardUIModel? {
        guard
            let imageData = draft.imageData,
            let image = UIImage(data: imageData)
        else {
            return nil
        }

        let yearValue: String? = draft.year
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ? nil : draft.year

        let powerValue: Int? = Int(draft.power)
        let gradeValue: Int = Int(draft.numGrade) ?? 0
        let downVotesValue: Int = Int(draft.downVotes) ?? 0

        let notesValue: String? = draft.notes
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ? nil : draft.notes

        return CardUIModel(
            id: Int(Date().timeIntervalSince1970),
            carImage: image,
            make: draft.make.trimmingCharacters(in: .whitespacesAndNewlines),
            model: draft.model.trimmingCharacters(in: .whitespacesAndNewlines),
            bodyType: draft.bodyType,
            numGrade: gradeValue,
            year: yearValue,
            power: powerValue,
            engineType: draft.engineType.trimmingCharacters(in: .whitespacesAndNewlines),
            userName: draft.userName.trimmingCharacters(in: .whitespacesAndNewlines),
            downVotes: downVotesValue,
            notes: notesValue,
            date: Date()
        )
    }

    func save() {
        guard let card = buildCard() else {
            print("Failed to build CardUIModel")
            return
        }

        print("Card created:")
        print("Make: \(card.make)")
        print("Model: \(card.model)")
        print("Body type: \(card.bodyType.rawValue)")
        print("Year: \(card.year ?? "nil")")
        print("Power: \(card.power.map(String.init) ?? "nil")")
        print("Engine: \(card.engineType)")
        print("User: \(card.userName)")
        print("DownVotes: \(card.downVotes)")
        print("Notes: \(card.notes ?? "nil")")
    }
}
