import XCTest
import SwiftUI
@testable import CarHunt

final class CardUIModelTests: XCTestCase {
    func testLetterGrade_whenScoreIs0_returnsF() {
        XCTAssertEqual(makeCard(numGrade: 0).letterGrade, "F")
    }

    func testLetterGrade_whenScoreIs100_returnsF() {
        XCTAssertEqual(makeCard(numGrade: 100).letterGrade, "F")
    }

    func testLetterGrade_whenScoreIs101_returnsE() {
        XCTAssertEqual(makeCard(numGrade: 101).letterGrade, "E")
    }

    func testLetterGrade_whenScoreIs199_returnsE() {
        XCTAssertEqual(makeCard(numGrade: 199).letterGrade, "E")
    }

    func testLetterGrade_whenScoreIs200_returnsD() {
        XCTAssertEqual(makeCard(numGrade: 200).letterGrade, "D")
    }

    func testLetterGrade_whenScoreIs299_returnsD() {
        XCTAssertEqual(makeCard(numGrade: 299).letterGrade, "D")
    }

    func testLetterGrade_whenScoreIs300_returnsC() {
        XCTAssertEqual(makeCard(numGrade: 300).letterGrade, "C")
    }

    func testLetterGrade_whenScoreIs399_returnsC() {
        XCTAssertEqual(makeCard(numGrade: 399).letterGrade, "C")
    }

    func testLetterGrade_whenScoreIs400_returnsB() {
        XCTAssertEqual(makeCard(numGrade: 400).letterGrade, "B")
    }

    func testLetterGrade_whenScoreIs499_returnsB() {
        XCTAssertEqual(makeCard(numGrade: 499).letterGrade, "B")
    }

    func testLetterGrade_whenScoreIs500_returnsA() {
        XCTAssertEqual(makeCard(numGrade: 500).letterGrade, "A")
    }

    func testLetterGrade_whenScoreIs599_returnsA() {
        XCTAssertEqual(makeCard(numGrade: 599).letterGrade, "A")
    }

    func testLetterGrade_whenScoreIs600_returnsAPlus() {
        XCTAssertEqual(makeCard(numGrade: 600).letterGrade, "A+")
    }

    func testLetterGrade_whenScoreIs699_returnsAPlus() {
        XCTAssertEqual(makeCard(numGrade: 699).letterGrade, "A+")
    }

    func testLetterGrade_whenScoreIs700_returnsS() {
        XCTAssertEqual(makeCard(numGrade: 700).letterGrade, "S")
    }

    func testLetterGrade_whenScoreIs799_returnsS() {
        XCTAssertEqual(makeCard(numGrade: 799).letterGrade, "S")
    }

    func testLetterGrade_whenScoreIs800_returnsSPlus() {
        XCTAssertEqual(makeCard(numGrade: 800).letterGrade, "S+")
    }

    func testLetterGrade_whenScoreIs899_returnsSPlus() {
        XCTAssertEqual(makeCard(numGrade: 899).letterGrade, "S+")
    }

    func testLetterGrade_whenScoreIs900_returnsX() {
        XCTAssertEqual(makeCard(numGrade: 900).letterGrade, "X")
    }

    func testLetterGrade_whenScoreIs1200_returnsX() {
        XCTAssertEqual(makeCard(numGrade: 1200).letterGrade, "X")
    }

    func testLetterGrade_whenScoreIsNegative_returnsNA() {
        XCTAssertEqual(makeCard(numGrade: -1).letterGrade, "N/A")
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
