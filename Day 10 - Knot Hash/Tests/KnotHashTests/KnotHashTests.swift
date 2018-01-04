import XCTest
@testable import KnotHash

class KnotHashTests: XCTestCase {

  func testPartOne() {
    let hasher = KnotHash(0...4)
    hasher.update([3, 4, 1, 5])
    XCTAssertEqual(hasher[0], 3)
    XCTAssertEqual(hasher[1], 4)
  }

  func testPartTwo() {
    XCTAssertEqual(KnotHash.hash("").description,         "a2582a3a0e66e6e86e3812dcb672a272")
    XCTAssertEqual(KnotHash.hash("AoC 2017").description, "33efeb34ea91902bb2f59c9920caa6cd")
    XCTAssertEqual(KnotHash.hash("1,2,3").description,    "3efbe78a8d82f29979031a4aa0b16a9d")
    XCTAssertEqual(KnotHash.hash("1,2,4").description,    "63960835bcdc130f0b66d7ff4f6a5a8e")
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
