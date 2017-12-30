import XCTest
@testable import PipeNetwork

class PipeNetworkTests: XCTestCase {
  static let PUZZLE = """
    0 <-> 2
    1 <-> 1
    2 <-> 0, 3, 4
    3 <-> 2, 4
    4 <-> 2, 3, 6
    5 <-> 6
    6 <-> 4, 5
  """

  func testPartOne() {
    let network = PipeNetwork(PipeNetworkTests.PUZZLE)!
    let p0 = network[program: 0]!
    XCTAssertEqual(p0.group.count, 6)
  }

  func testPartTwo() {
    let network = PipeNetwork(PipeNetworkTests.PUZZLE)!
    XCTAssertEqual(network.groups.count, 2)
  }
}

#if os(Linux)
extension PipeNetworkTests {
  static var allTests: [(String, (PipeNetworkTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
