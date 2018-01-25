import XCTest
@testable import SpiralMemory

class SpiralMemoryTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(SpiralMemory(   1).snake_distance(),  0)
    XCTAssertEqual(SpiralMemory(   9).snake_distance(),  2)
    XCTAssertEqual(SpiralMemory(  12).snake_distance(),  3)
    XCTAssertEqual(SpiralMemory(  23).snake_distance(),  2)
    XCTAssertEqual(SpiralMemory(1024).snake_distance(), 31)
  }

  func testPartTwo() {
    XCTAssertEqual(SpiralMemory(   1).stress_test_gt(),   2)
    XCTAssertEqual(SpiralMemory(   5).stress_test_gt(),  10)
    XCTAssertEqual(SpiralMemory(  23).stress_test_gt(),  25)
    XCTAssertEqual(SpiralMemory(  59).stress_test_gt(), 122)
    XCTAssertEqual(SpiralMemory( 747).stress_test_gt(), 806)
  }
}

#if os(Linux)
extension SpiralMemoryTests {
  static var allTests: [(String, (SpiralMemoryTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif // os(Linux)
