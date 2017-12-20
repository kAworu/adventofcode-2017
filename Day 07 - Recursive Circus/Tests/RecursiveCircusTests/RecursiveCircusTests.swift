import XCTest
@testable import RecursiveCircus

class RecursiveCircusTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(RecursiveCircus("""
    pbga (66)
    xhth (57)
    ebii (61)
    havc (66)
    ktlj (57)
    fwft (72) -> ktlj, cntj, xhth
    qoyq (66)
    padx (45) -> pbga, havc, qoyq
    tknk (41) -> ugml, padx, fwft
    jptl (61)
    ugml (68) -> gyxo, ebii, jptl
    gyxo (61)
    cntj (57)
    """)!.bottom_program, "tknk")
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension RecursiveCircusTests {
  static var allTests: [(String, (RecursiveCircusTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
