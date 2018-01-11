import XCTest
@testable import PermutationPromenade

class PermutationPromenadeTests: XCTestCase {

  func testPartOne() {
    let dancers = PermutationPromenade(count: 5)
    XCTAssertEqual("\(dancers)", "abcde")
    XCTAssertEqual("\(dancers ♫ "s1")", "eabcd")
    XCTAssertEqual("\(dancers ♫ "s1,x3/4")", "eabdc")
    XCTAssertEqual("\(dancers ♫ "s1,x3/4,pe/b")", "baedc")
  }

  func testPartTwo() {
    let dancers = PermutationPromenade(count: 5)
    XCTAssertEqual("\(dancers ♫ "s1,x3/4,pe/b" ♯ 2)", "ceadb")
    // NOTE: for this count/dance combination their is a cycle of size=4.
    XCTAssertEqual("\(dancers ♫ "s1,x3/4,pe/b" ♯ 1_000_000_000)", "abcde")
  }
}

#if os(Linux)
extension PermutationPromenadeTests {
  static var allTests: [(String, (PermutationPromenadeTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
