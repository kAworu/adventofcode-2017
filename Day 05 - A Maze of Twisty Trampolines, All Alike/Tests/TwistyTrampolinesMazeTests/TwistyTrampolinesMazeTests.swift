import XCTest
@testable import TwistyTrampolinesMaze

class TwistyTrampolinesMazeTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(TwistyTrampolinesMaze([0, 3, 0, 1, -3]).strange_jumps_exit(), 5)
  }

  func testPartTwo() {
    XCTAssertEqual(TwistyTrampolinesMaze([0, 3, 0, 1, -3]).stranger_jumps_exit(), 10)
  }
}

#if os(Linux)
extension TwistyTrampolinesMazeTests {
  static var allTests: [(String, (TwistyTrampolinesMazeTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
