import XCTest
@testable import Tubes

class TubesTests: XCTestCase {
  static let PUZZLE = [
    "     |          ",
    "     |  +--+    ",
    "     A  |  C    ",
    " F---|----E|--+ ",
    "     |  |  |  D ",
    "     +B-+  +--+ ",
  ]

  func testPartOne() {
    let path    = Tubes.RoutingDiagram(TubesTests.PUZZLE).path()
    let letters = path.map { "\($0)" }
    XCTAssertEqual(letters.joined(), "ABCDEF")
  }

  func testPartTwo() {
    let path    = Tubes.RoutingDiagram(TubesTests.PUZZLE).path()
    let letters = path.map { "\($0)" }
    XCTAssertEqual(letters.count, 38)
  }
}

#if os(Linux)
extension TubesTests {
  static var allTests: [(String, (TubesTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
