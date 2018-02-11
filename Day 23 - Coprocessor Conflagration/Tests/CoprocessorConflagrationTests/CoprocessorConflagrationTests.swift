import XCTest
@testable import CoprocessorConflagration

class CoprocessorConflagrationTests: XCTestCase {
  // Well, no example from the README :(
}

#if os(Linux)
extension CoprocessorConflagrationTests {
  static var allTests: [(String, (CoprocessorConflagrationTests) -> () throws -> Void)] {
    return [
      // NOPE.
    ]
  }
}
#endif
