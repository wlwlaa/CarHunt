import XCTest

final class SmokeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchAndTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let cameraTab = tabBar.buttons.element(boundBy: 0)
        let collectionTab = tabBar.buttons.element(boundBy: 1)

        XCTAssertTrue(cameraTab.waitForExistence(timeout: 5))
        XCTAssertTrue(collectionTab.waitForExistence(timeout: 5))

        collectionTab.tap()
        XCTAssertTrue(collectionTab.exists)

        cameraTab.tap()
        XCTAssertTrue(cameraTab.exists)
    }
}
