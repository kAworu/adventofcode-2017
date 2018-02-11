import XCTest
@testable import CoprocessorConflagration

class CoprocessorConflagrationTests: XCTestCase {

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension CoprocessorConflagrationTests {
  static var allTests: [(String, (CoprocessorConflagrationTests) -> () throws -> Void)] {
    return [
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
