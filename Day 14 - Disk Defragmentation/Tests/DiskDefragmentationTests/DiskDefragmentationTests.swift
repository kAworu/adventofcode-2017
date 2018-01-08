import XCTest
@testable import DiskDefragmentation

class DiskDefragmentationTests: XCTestCase {
  static let disk = DiskDefragmentation(key: "flqrgnkx")

  func testPartOne() {
    XCTAssertEqual(DiskDefragmentationTests.disk.used_square_count, 8108)
  }

  func testPartTwo() {
    XCTAssertEqual(DiskDefragmentationTests.disk.region_count, 1242)
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
