import XCTest
@testable import KnotHash

class KnotHashTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(KnotHash(0...4).hash(lengths: [3, 4, 1, 5]), 12)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension KnotHashTests {
  static var allTests: [(String, (KnotHashTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
