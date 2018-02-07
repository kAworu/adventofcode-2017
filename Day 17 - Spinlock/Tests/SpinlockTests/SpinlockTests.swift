import XCTest
@testable import Spinlock

class SpinlockTests: XCTestCase {

  func testPartOne() {
    let lock = Spinlock(step: 3)
    XCTAssertEqual(String(reflecting: lock), "(0)")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0 (1)")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0 (2) 1")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0  2 (3) 1")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0  2 (4) 3  1")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0 (5) 2  4  3  1")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0  5  2  4  3 (6) 1")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0  5 (7) 2  4  3  6  1")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0  5  7  2  4  3 (8) 6  1")
    lock.spin()
    XCTAssertEqual(String(reflecting: lock), "0 (9) 5  7  2  4  3  8  6  1")
    lock.spin(count: 2017 - 9)
    XCTAssertEqual(lock.next_to(2017)!, 638)
  }

  func testPartTwo() {
    let lock = FakeSpinlock(step: 3)
    XCTAssertEqual(lock.next_to_zero, nil)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 1)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 2)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 2)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 2)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 5)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 5)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 5)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 5)
    lock.spin()
    XCTAssertEqual(lock.next_to_zero, 9)
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
