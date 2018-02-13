import XCTest
@testable import ElectromagneticMoat

class ElectromagneticMoatTests: XCTestCase {
  static let PUZZLE = [
    "0/2", "2/2", "2/3", "3/4", "3/5", "0/1", "10/1", "9/10"
  ]

  func testPartOne() {
    let puzzle = ElectromagneticMoatTests.PUZZLE
    let moat = ElectromagneticMoat(components: puzzle)!
    let bridge = moat.strongest()
    XCTAssertEqual("\(bridge)", "0/1--10/1--9/10")
    XCTAssertEqual(bridge.strength, 31)
  }

  func testPartTwo() {
    let puzzle = ElectromagneticMoatTests.PUZZLE
    let moat = ElectromagneticMoat(components: puzzle)!
    let bridge = moat.longest()
    XCTAssertEqual("\(bridge)", "0/2--2/2--2/3--3/5")
    XCTAssertEqual(bridge.strength, 19)
  }
}

#if os(Linux)
extension ElectromagneticMoatTests {
  static var allTests: [(String, (ElectromagneticMoatTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
