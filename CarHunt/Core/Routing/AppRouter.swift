import SwiftUI
import Combine

@MainActor
protocol AppRouting: AnyObject {
    func push(_ route: AppRoute)
    func pop()
    func popToRoot()

    func present(_ route: AppRoute)
    func presentCardSettings(with card: CardUIModel, draftDataModel: CardDataModel, photoData: Data?)
    func dismissPresented()
    func openCollection(showingCardID cardID: UUID?)
    func open(_ route: AppRoute)
}

@MainActor
final class AppRouter: ObservableObject, AppRouting {
    @Published var path = NavigationPath()

    @Published var presented: AppRoute?
    @Published var presentedCardSettingsCard: CardUIModel?
    @Published var presentedCardSettingsDraftDataModel: CardDataModel?
    @Published var presentedCardSettingsPhotoData: Data?
    @Published var pendingCollectionCardID: UUID?
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
            presentedCardSettingsDraftDataModel = nil
            presentedCardSettingsPhotoData = nil
        }
        presented = route
    }

    func presentCardSettings(with card: CardUIModel, draftDataModel: CardDataModel, photoData: Data?) {
        presentedCardSettingsCard = card
        presentedCardSettingsDraftDataModel = draftDataModel
        presentedCardSettingsPhotoData = photoData
        presented = .cardSettings
    }

    func dismissPresented() {
        presentedCardSettingsCard = nil
        presentedCardSettingsDraftDataModel = nil
        presentedCardSettingsPhotoData = nil
        presented = nil
    }

    func openCollection(showingCardID cardID: UUID?) {
        dismissPresented()
        pendingCollectionCardID = cardID
        selectedTab = .collection
    }

    func open(_ route: AppRoute) {
        switch route {
        case .camera:
            dismissPresented()
            pendingCollectionCardID = nil
            selectedTab = .camera

        case .map:
            dismissPresented()
            pendingCollectionCardID = nil
            selectedTab = .map

        case .collection:
            openCollection(showingCardID: nil)

        case .cardSettings:
            present(route)
        }
    }
}
