import SwiftUI
import Combine

@MainActor
protocol AppRouting: AnyObject {
    func push(_ route: AppRoute)
    func pop()
    func popToRoot()

    func present(_ route: AppRoute)
    func presentCardSettings(with card: CardUIModel, photoData: Data?)
    func dismissPresented()
    func open(_ route: AppRoute)
}

@MainActor
final class AppRouter: ObservableObject, AppRouting {
    @Published var path = NavigationPath()

    @Published var presented: AppRoute?
    @Published var presentedCardSettingsCard: CardUIModel?
    @Published var presentedCardSettingsPhotoData: Data?
    @Published var selectedTab: AppTab = .camera

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func present(_ route: AppRoute) {
        if route != .cardSettings {
            presentedCardSettingsCard = nil
            presentedCardSettingsPhotoData = nil
        }
        presented = route
    }

    func presentCardSettings(with card: CardUIModel, photoData: Data?) {
        presentedCardSettingsCard = card
        presentedCardSettingsPhotoData = photoData
        presented = .cardSettings
    }

    func dismissPresented() {
        presentedCardSettingsCard = nil
        presentedCardSettingsPhotoData = nil
        presented = nil
    }

    func open(_ route: AppRoute) {
        switch route {
        case .camera:
            dismissPresented()
            selectedTab = .camera

        case .collection:
            dismissPresented()
            selectedTab = .collection

        case .cardSettings:
            present(route)
        }
    }
}
