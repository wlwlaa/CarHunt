import XCTest
import SwiftUI
@testable import CarHunt

final class AppRouterTests: XCTestCase {
    func testPresent_setsPresentedRoute() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.present(.cardSettings)
        }

        let presented = await MainActor.run { sut.presented?.id }
        XCTAssertEqual(presented, AppRoute.cardSettings.id)
    }

    func testDismissPresented_clearsPresentedRoute() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.present(.cardSettings)
            sut.dismissPresented()
        }

        let presented = await MainActor.run { sut.presented }
        XCTAssertNil(presented)
    }

    func testOpenCollection_switchesSelectedTabAndDismissesSheet() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.present(.cardSettings)
            sut.open(.collection)
        }

        let selectedTab = await selectedTabName(from: sut)
        let presented = await MainActor.run { sut.presented }

        XCTAssertEqual(selectedTab, "collection")
        XCTAssertNil(presented)
    }

    func testOpenCamera_switchesSelectedTabAndDismissesSheet() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.present(.cardSettings)
            sut.open(.camera)
        }

        let selectedTab = await selectedTabName(from: sut)
        let presented = await MainActor.run { sut.presented }

        XCTAssertEqual(selectedTab, "camera")
        XCTAssertNil(presented)
    }

    func testOpenCardSettings_setsPresentedRoute() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.open(.cardSettings)
        }

        let presented = await MainActor.run { sut.presented?.id }
        XCTAssertEqual(presented, AppRoute.cardSettings.id)
    }

    func testPush_appendsRouteToPath() async {
        let sut = await MainActor.run { AppRouter() }

        let initialCount = await MainActor.run { sut.path.count }

        await MainActor.run {
            sut.push(.cardSettings)
        }

        let finalCount = await MainActor.run { sut.path.count }
        XCTAssertEqual(finalCount, initialCount + 1)
    }

    func testPop_removesLastRouteFromPath() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.push(.cardSettings)
            sut.push(.collection)
        }

        let countBeforePop = await MainActor.run { sut.path.count }

        await MainActor.run {
            sut.pop()
        }

        let countAfterPop = await MainActor.run { sut.path.count }
        XCTAssertEqual(countAfterPop, countBeforePop - 1)
    }

    func testPop_whenPathIsEmpty_doesNothing() async {
        let sut = await MainActor.run { AppRouter() }

        let countBeforePop = await MainActor.run { sut.path.count }

        await MainActor.run {
            sut.pop()
        }

        let countAfterPop = await MainActor.run { sut.path.count }
        XCTAssertEqual(countAfterPop, countBeforePop)
    }

    func testPopToRoot_clearsPath() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.push(.cardSettings)
            sut.push(.collection)
            sut.popToRoot()
        }

        let pathCount = await MainActor.run { sut.path.count }
        XCTAssertEqual(pathCount, 0)
    }

    private func selectedTabName(from router: AppRouter) async -> String {
        await MainActor.run {
            switch router.selectedTab {
            case .camera:
                return "camera"
            case .collection:
                return "collection"
            case .map:
                return "map"
            }
        }
    }
}
