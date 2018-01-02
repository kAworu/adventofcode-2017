import XCTest
@testable import LikableRegisters

class LikableRegistersTests: XCTestCase {
  static let PUZZLE = """
    b inc 5 if a > 1
    a inc 1 if b < 5
    c dec -10 if a >= 1
    c inc -20 if c == 10
  """

  func testPartOne() {
    let program = LikableRegisters(LikableRegistersTests.PUZZLE)!
    let cpu = LikableRegisters.Processor()
    let _ = program.compute(on: cpu)
    XCTAssertEqual(cpu.max?.key, "a")
    XCTAssertEqual(cpu.max?.value, 1)
  }

  func testPartTwo() {
    let program = LikableRegisters(LikableRegistersTests.PUZZLE)!
    let cpu = LikableRegisters.Processor()
    let all_time_max = program.compute(on: cpu)
    XCTAssertEqual(all_time_max?.key, "c")
    XCTAssertEqual(all_time_max?.value, 10)
  }
}

#if os(Linux)
extension LikableRegistersTests {
  static var allTests: [(String, (LikableRegistersTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
