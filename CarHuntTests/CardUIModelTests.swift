import XCTest
import SwiftUI
@testable import CarHunt

final class CardUIModelTests: XCTestCase {
    func testLetterGrade_whenScoreIs50_returnsF() {
        let model = makeCard(numGrade: 50)
        XCTAssertEqual(model.letterGrade, "F")
    }

    func testLetterGrade_whenScoreIs150_returnsE() {
        let model = makeCard(numGrade: 150)
        XCTAssertEqual(model.letterGrade, "E")
    }

    func testLetterGrade_whenScoreIs250_returnsD() {
        let model = makeCard(numGrade: 250)
        XCTAssertEqual(model.letterGrade, "D")
    }

    func testLetterGrade_whenScoreIs350_returnsC() {
        let model = makeCard(numGrade: 350)
        XCTAssertEqual(model.letterGrade, "C")
    }

    func testLetterGrade_whenScoreIs450_returnsB() {
        let model = makeCard(numGrade: 450)
        XCTAssertEqual(model.letterGrade, "B")
    }

    func testLetterGrade_whenScoreIs550_returnsA() {
        let model = makeCard(numGrade: 550)
        XCTAssertEqual(model.letterGrade, "A")
    }

    func testLetterGrade_whenScoreIs650_returnsAPlus() {
        let model = makeCard(numGrade: 650)
        XCTAssertEqual(model.letterGrade, "A+")
    }

    func testLetterGrade_whenScoreIs750_returnsS() {
        let model = makeCard(numGrade: 750)
        XCTAssertEqual(model.letterGrade, "S")
    }

    func testLetterGrade_whenScoreIs850_returnsSPlus() {
        let model = makeCard(numGrade: 850)
        XCTAssertEqual(model.letterGrade, "S+")
    }

    func testLetterGrade_whenScoreIs950_returnsX() {
        let model = makeCard(numGrade: 950)
        XCTAssertEqual(model.letterGrade, "X")
    }

    private func makeCard(numGrade: Int) -> CardUIModel {
        CardUIModel(
            id: 1,
            carImage: Image(systemName: "car.fill"),
            make: "BMW",
            model: "M4",
            bodyType: .coupe,
            numGrade: numGrade,
            year: "2022",
            power: 503,
            engineType: "Petrol",
            downVotes: 0,
            notes: nil,
            date: Date()
        )
    }
}
