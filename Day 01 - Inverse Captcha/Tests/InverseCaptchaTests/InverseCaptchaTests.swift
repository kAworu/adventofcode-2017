import XCTest
@testable import InverseCaptcha

class InverseCaptchaTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(InverseCaptcha("1122").neighbour_sum(),     3)
    XCTAssertEqual(InverseCaptcha("1111").neighbour_sum(),     4)
    XCTAssertEqual(InverseCaptcha("1234").neighbour_sum(),     0)
    XCTAssertEqual(InverseCaptcha("91212129").neighbour_sum(), 9)
  }

  func testPartTwo() {
    XCTAssertEqual(InverseCaptcha("1212").halfway_around_sum(),      6)
    XCTAssertEqual(InverseCaptcha("1221").halfway_around_sum(),      0)
    XCTAssertEqual(InverseCaptcha("123425").halfway_around_sum(),    4)
    XCTAssertEqual(InverseCaptcha("123123").halfway_around_sum(),   12)
    XCTAssertEqual(InverseCaptcha("12131415").halfway_around_sum(),  4)
  }
}

#if os(Linux)
extension InverseCaptchaTests {
  static var allTests: [(String, (InverseCaptchaTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif // os(Linux)
