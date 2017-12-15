import XCTest
@testable import MemoryReallocation

class MemoryReallocationTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(MemoryReallocation([0, 2, 7, 0]).debug().before_looping, 5)
  }

  func testPartTwo() {
    XCTAssertEqual(MemoryReallocation([0, 2, 7, 0]).debug().loop, 4)
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
