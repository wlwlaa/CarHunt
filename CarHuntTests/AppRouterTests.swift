import XCTest
@testable import CarHunt

final class AppRouterTests: XCTestCase {
    func testPresent_setsPresentedRoute() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.present(.cardSettings)
        }

        let presented = await MainActor.run { sut.presented }
        XCTAssertEqual(presented, .cardSettings)
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

        let selectedTab = await MainActor.run { sut.selectedTab }
        let presented = await MainActor.run { sut.presented }

        XCTAssertEqual(selectedTab, .collection)
        XCTAssertNil(presented)
    }

    func testOpenCamera_switchesSelectedTabAndDismissesSheet() async {
        let sut = await MainActor.run { AppRouter() }

        await MainActor.run {
            sut.present(.cardSettings)
            sut.open(.camera)
        }

        let selectedTab = await MainActor.run { sut.selectedTab }
        let presented = await MainActor.run { sut.presented }

        XCTAssertEqual(selectedTab, .camera)
        XCTAssertNil(presented)
    }
}
