import XCTest
@testable import SpiralMemory

#if os(Linux)
extension SpiralMemoryTests {
  static var allTests: [(String, (SpiralMemoryTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
    ]
  }
}
#endif

class SpiralMemoryTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(SpiralMemory(   1).snake_distance,  0)
    XCTAssertEqual(SpiralMemory(   9).snake_distance,  2)
    XCTAssertEqual(SpiralMemory(  12).snake_distance,  3)
    XCTAssertEqual(SpiralMemory(  23).snake_distance,  2)
    XCTAssertEqual(SpiralMemory(1024).snake_distance, 31)
  }
}
