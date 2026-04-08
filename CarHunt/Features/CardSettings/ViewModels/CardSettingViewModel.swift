import Foundation
import SwiftUI
import Combine

protocol CardAutofillServicing {
    func autofill(from photoData: Data) async throws -> CardFromImageResponse
}

struct CardAutofillService: CardAutofillServicing {
    private struct CardFromImageRequest: Encodable {
        let imageBase64: String
    }

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func autofill(from photoData: Data) async throws -> CardFromImageResponse {
        let request = CardFromImageRequest(
            imageBase64: "data:image/jpeg;base64,\(photoData.base64EncodedString())"
        )
        let body = try JSONEncoder().encode(request)
        let endpoint = NetworkEndpoint(
            path: "/cards/from-image",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body
        )

        return try await networkService.request(endpoint)
    }
}

struct CardFromImageResponse: Decodable {
    let make: String
    let model: String
    let bodyType: String
    let numGrade: Int
    let year: String
    let power: Int
    let notes: String
}

@MainActor
final class CardSettingViewModel: ObservableObject {
    enum RequiredField: Hashable {
        case make
        case model
        case bodyType
    }

    @Published var editableCard: CardUIModel
    @Published var isAutofillInProgress = false
    @Published private(set) var invalidFieldsForFlash: Set<RequiredField> = []
    @Published private(set) var validationFlashTrigger = 0

    private let router: any AppRouting
    private let storage: CardStorage
    private let initialPhotoData: Data?
    private let cardAutofillService: CardAutofillServicing?
    private var didStartAutofill = false

    init(
        router: any AppRouting,
        storage: CardStorage,
        initialCard: CardUIModel = .draft,
        initialPhotoData: Data? = nil,
        cardAutofillService: CardAutofillServicing? = nil
    ) {
        self.router = router
        self.storage = storage
        self.editableCard = initialCard
        self.initialPhotoData = initialPhotoData
        self.cardAutofillService = cardAutofillService
    }

    func addCard() {
        let invalidFields = requiredFieldsValidationResult
        guard invalidFields.isEmpty else {
            invalidFieldsForFlash = invalidFields
            validationFlashTrigger += 1
            return
        }

        editableCard.make = normalizedMake
        editableCard.model = normalizedModel

        do {
            try storage.addCard(editableCard.asDataModel)
            openCollection()
        } catch {
            print("Card save error: \(error.localizedDescription)")
        }
    }

    func openCollection() {
        router.open(.collection)
    }
    
    func openCamera() {
        router.open(.camera)
    }

    func autofillIfNeeded() async {
        guard !didStartAutofill else { return }
        didStartAutofill = true

        guard
            let initialPhotoData,
            let cardAutofillService
        else { return }

        isAutofillInProgress = true
        defer { isAutofillInProgress = false }

        do {
            let response = try await cardAutofillService.autofill(from: initialPhotoData)
            applyAutofill(response)
        } catch {
            print("Card autofill error: \(error.localizedDescription)")
        }
    }

    private func applyAutofill(_ response: CardFromImageResponse) {
        editableCard.make = response.make
        editableCard.model = response.model
        editableCard.numGrade = response.numGrade
        editableCard.power = response.power
        editableCard.notes = response.notes
        editableCard.year = Int(response.year.trimmingCharacters(in: .whitespacesAndNewlines))
        editableCard.bodyType = BodyType(rawValue: response.bodyType) ?? .empty
    }

    private var normalizedMake: String {
        editableCard.make.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedModel: String {
        editableCard.model.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var requiredFieldsValidationResult: Set<RequiredField> {
        var result: Set<RequiredField> = []

        if normalizedMake.isEmpty {
            result.insert(.make)
        }
        if normalizedModel.isEmpty {
            result.insert(.model)
        }
        if editableCard.bodyType == .empty {
            result.insert(.bodyType)
        }

        return result
    }
}
