import XCTest
@testable import HighEntropyPassphrases

class HighEntropyPassphrasesTests: XCTestCase {

  func testPartOne() {
    XCTAssert(HighEntropyPassphrases("aa bb cc dd ee").valid)
    XCTAssertFalse(HighEntropyPassphrases("aa bb cc dd aa").valid)
    XCTAssert(HighEntropyPassphrases("aa bb cc dd aaa").valid)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension HighEntropyPassphrasesTests {
  static var allTests: [(String, (HighEntropyPassphrasesTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
