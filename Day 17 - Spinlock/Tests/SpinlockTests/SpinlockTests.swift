import XCTest
@testable import Spinlock

class SpinlockTests: XCTestCase {

  func testPartOne() {
    var lock = Spinlock(step: 3)
    XCTAssertEqual("\(lock)", "(0)")
    lock.spin()
    XCTAssertEqual("\(lock)", "0 (1)")
    lock.spin()
    XCTAssertEqual("\(lock)", "0 (2) 1")
    lock.spin()
    XCTAssertEqual("\(lock)", "0  2 (3) 1")
    lock.spin()
    XCTAssertEqual("\(lock)", "0  2 (4) 3  1")
    lock.spin()
    XCTAssertEqual("\(lock)", "0 (5) 2  4  3  1")
    lock.spin()
    XCTAssertEqual("\(lock)", "0  5  2  4  3 (6) 1")
    lock.spin()
    XCTAssertEqual("\(lock)", "0  5 (7) 2  4  3  6  1")
    lock.spin()
    XCTAssertEqual("\(lock)", "0  5  7  2  4  3 (8) 6  1")
    lock.spin()
    XCTAssertEqual("\(lock)", "0 (9) 5  7  2  4  3  8  6  1")
    lock = Spinlock(step: 3)
    lock.spin(count: 2017)
    XCTAssertEqual(lock[1], 638)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension SpinlockTests {
  static var allTests: [(String, (SpinlockTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
