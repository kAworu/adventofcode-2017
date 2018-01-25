import XCTest
@testable import StreamProcessing

class StreamProcessingTests: XCTestCase {

  func testPartOne() {
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
    [
      "<>": 0,
      "<random characters>": 17,
      "<<<<>": 3,
      "<{!>}>": 2,
      "<!!>": 0,
      "<!!!>>": 0,
      "<{o\"i!a,<{i<a>": 10,
    ].forEach() { test in
      let stream = StreamProcessing.parse(test.key)!
      XCTAssertEqual(stream.garbage_count(), test.value)
    }
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
