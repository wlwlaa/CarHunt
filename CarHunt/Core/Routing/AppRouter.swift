import SwiftUI
import Combine

@MainActor
protocol AppRouting: AnyObject {
    func push(_ route: AppRoute)
    func pop()
    func popToRoot()

    func present(_ route: AppRoute)
    func dismissPresented()
}

final class AppRouter: ObservableObject, AppRouting {
    @Published var path = NavigationPath()

    @Published var presented: AppRoute?

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
        presented = route
    }

    func dismissPresented() {
        presented = nil
    }
}
