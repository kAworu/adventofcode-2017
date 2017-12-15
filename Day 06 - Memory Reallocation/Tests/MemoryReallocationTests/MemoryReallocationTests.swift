import XCTest
@testable import MemoryReallocation

class MemoryReallocationTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(MemoryReallocation([0, 2, 7, 0]).redistribution_cycles_count, 5)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension MemoryReallocationTests {
  static var allTests: [(String, (MemoryReallocationTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
