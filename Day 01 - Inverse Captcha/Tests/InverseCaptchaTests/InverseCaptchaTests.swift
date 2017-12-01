import XCTest
@testable import InverseCaptcha

#if os(Linux)
extension InverseCaptchaTests {
  static var allTests: [(String, (InverseCaptchaTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif

class InverseCaptchaTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(InverseCaptcha("1122").solve_next(),     3)
    XCTAssertEqual(InverseCaptcha("1111").solve_next(),     4)
    XCTAssertEqual(InverseCaptcha("1234").solve_next(),     0)
    XCTAssertEqual(InverseCaptcha("91212129").solve_next(), 9)
  }

  func testPartTwo() {
    XCTAssertEqual(InverseCaptcha("1212").solve_halfway_around(),      6)
    XCTAssertEqual(InverseCaptcha("1221").solve_halfway_around(),      0)
    XCTAssertEqual(InverseCaptcha("123425").solve_halfway_around(),    4)
    XCTAssertEqual(InverseCaptcha("123123").solve_halfway_around(),   12)
    XCTAssertEqual(InverseCaptcha("12131415").solve_halfway_around(),  4)
  }
}
