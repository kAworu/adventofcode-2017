import XCTest
@testable import Duet

class DuetTests: XCTestCase {
  static let PUZZLE = """
    set a 1
    add a 2
    mul a a
    mod a 5
    snd a
    set a 0
    rcv a
    jgz a -1
    set a 1
    jgz a -2
  """

  func testPartOne() {
    let instructions = Duet.Assembly(DuetTests.PUZZLE)!
    var called = 0
    let processor = Duet.Processor(rcv: {
      called += 1
      XCTAssertEqual($0, 4)
      return false
    })
    processor.execute(instructions)
    XCTAssertEqual(called, 1)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension DuetTests {
  static var allTests: [(String, (DuetTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
