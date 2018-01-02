import XCTest
@testable import RecursiveCircus

class RecursiveCircusTests: XCTestCase {
  static let PUZZLE = """
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
  """

  func testPartOne() {
    let tower = RecursiveCircus(RecursiveCircusTests.PUZZLE)!
    XCTAssertEqual(tower.bottom_program!.name, "tknk")
  }

  func testPartTwo() {
    let tower = RecursiveCircus(RecursiveCircusTests.PUZZLE)!
    do {
      let _ = try tower.bottom_program!.total_weight()
      XCTFail("Expected an Error to be thrown.")
    } catch let err as RecursiveCircus.InvalidWeightError {
      XCTAssertEqual(err.culprit.name, "ugml")
      XCTAssertEqual(err.corrected_weight, 60)
    } catch {
      XCTFail("Wrong error type, expected ProgrammingError.")
    }
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
