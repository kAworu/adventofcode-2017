import XCTest
@testable import LikableRegisters

class LikableRegistersTests: XCTestCase {

  func testPartOne() {
    let program = LikableRegisters("""
      b inc 5 if a > 1
      a inc 1 if b < 5
      c dec -10 if a >= 1
      c inc -20 if c == 10
    """)!
    let cpu = Processor()
    program.compute(on: cpu)
    XCTAssertEqual(cpu.max?.key, "a")
    XCTAssertEqual(cpu.max?.value, 1)
  }

  func testPartTwo() {
    // TODO
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
