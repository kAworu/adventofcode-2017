import XCTest
@testable import DuelingGenerators

class DuelingGeneratorsTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(DuelingGenerators(A: 65, B: 8921).final_count(sample: 2), 0)
    XCTAssertEqual(DuelingGenerators(A: 65, B: 8921).final_count(sample: 3), 1)
    XCTAssertEqual(DuelingGenerators(A: 65, B: 8921).final_count(sample: 5), 1)
    XCTAssertEqual(DuelingGenerators(A: 65, B: 8921).final_count(), 588)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension DuelingGeneratorsTests {
  static var allTests: [(String, (DuelingGeneratorsTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
