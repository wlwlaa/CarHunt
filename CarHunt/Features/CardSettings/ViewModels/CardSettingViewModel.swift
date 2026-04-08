import Foundation
import SwiftUI
import Combine

@MainActor
final class CardSettingViewModel: ObservableObject {
    @Published var editableCard: CardUIModel

    private let router: any AppRouting

    init(router: any AppRouting, initialCard: CardUIModel = .draft) {
        self.router = router
        self.editableCard = initialCard
    }

    func openCollection() {
        router.open(.collection)
    }
    
    func openCamera() {
        router.open(.camera)
    }
}
