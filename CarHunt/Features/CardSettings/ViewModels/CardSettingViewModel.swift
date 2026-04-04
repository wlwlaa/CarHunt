import Foundation
import Combine

final class CardSettingViewModel: ObservableObject {
    private let router: any AppRouting

    init(router: any AppRouting) {
        self.router = router
    }

    func openCollection() {
        router.open(.collection)
    }
}
