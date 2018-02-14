import XCTest
@testable import HaltingProblem

class HaltingProblemTests: XCTestCase {

  func testPartOne() throws {
    let puzzle = """
    Begin in state A.
    Perform a diagnostic checksum after 6 steps.

    In state A:
      If the current value is 0:
        - Write the value 1.
        - Move one slot to the right.
        - Continue with state B.
      If the current value is 1:
        - Write the value 0.
        - Move one slot to the left.
        - Continue with state B.

    In state B:
      If the current value is 0:
        - Write the value 1.
        - Move one slot to the left.
        - Continue with state A.
      If the current value is 1:
        - Write the value 1.
        - Move one slot to the right.
        - Continue with state A.
    """
    let machine = try HaltingProblem(blueprint: puzzle)
    let tape = machine.run()
    XCTAssertEqual(tape.checksum(), 3)
  }
}

#if os(Linux)
extension HaltingProblemTests {
  static var allTests: [(String, (HaltingProblemTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
    ]
  }
}
#endif
