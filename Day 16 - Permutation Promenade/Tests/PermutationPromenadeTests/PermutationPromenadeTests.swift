import XCTest
@testable import PermutationPromenade

class PermutationPromenadeTests: XCTestCase {

  func testPartOne() {
    let dancers = PermutationPromenade(count: 5)
    XCTAssertEqual("\(dancers)", "abcde")
    dancers ♫ "s1"
    XCTAssertEqual("\(dancers)", "eabcd")
    dancers ♫ "x3/4"
    XCTAssertEqual("\(dancers)", "eabdc")
    dancers ♫ "pe/b"
    XCTAssertEqual("\(dancers)", "baedc")
  }

  func testPartTwo() {
    let dancers = PermutationPromenade(count: 5)
    dancers ♫ "s1,x3/4,pe/b" ♯ 2
    XCTAssertEqual("\(dancers)", "ceadb")
    // NOTE: for this count/dance combination their is a cycle of size=4.
    dancers ♫ "s1,x3/4,pe/b" ♯ (1_000_000_000 - 2)
    XCTAssertEqual("\(dancers)", "abcde")
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
