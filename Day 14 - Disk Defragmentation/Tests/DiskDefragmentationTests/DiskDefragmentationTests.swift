import XCTest
@testable import DiskDefragmentation

class DiskDefragmentationTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(DiskDefragmentation(key: "flqrgnkx").used_square_count, 8108)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension DiskDefragmentationTests {
  static var allTests: [(String, (DiskDefragmentationTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
