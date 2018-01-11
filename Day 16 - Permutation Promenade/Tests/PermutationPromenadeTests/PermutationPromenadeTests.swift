import XCTest
@testable import PermutationPromenade

class PermutationPromenadeTests: XCTestCase {

  func testPartOne() {
    let programs = PermutationPromenade(count: 5)
    XCTAssertEqual(programs.description, "abcde")
    programs.dance(tune: "s1")
    XCTAssertEqual(programs.description, "eabcd")
    programs.dance(tune: "x3/4")
    XCTAssertEqual(programs.description, "eabdc")
    programs.dance(tune: "pe/b")
    XCTAssertEqual(programs.description, "baedc")
  }

  func testPartTwo() {
    // TODO
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
