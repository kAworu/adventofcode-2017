import XCTest
@testable import StreamProcessing

class StreamProcessingTests: XCTestCase {

  func testPartOne() {
    //XCTAssertEqual(StreamProcessing.parse("{}")!.score(), 1)
    [
      "{}": 1,
      "{{{}}}": 6,
      "{{},{}}": 5,
      "{{{},{},{{}}}}": 16,
      "{<a>,<a>,<a>,<a>}": 1,
      "{{<ab>},{<ab>},{<ab>},{<ab>}}": 9,
      "{{<!!>},{<!!>},{<!!>},{<!!>}}": 9,
      "{{<a!>},{<a!>},{<a!>},{<ab>}}": 3,
    ].forEach() { test in
      let stream = StreamProcessing.parse(test.key)!
      XCTAssertEqual(stream.score(), test.value)
    }
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension StreamProcessingTests {
  static var allTests: [(String, (StreamProcessingTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
