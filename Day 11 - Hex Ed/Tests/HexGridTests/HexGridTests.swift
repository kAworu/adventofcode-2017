import XCTest
@testable import HexGrid

class HexGridTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(HexGrid.walk(path: "ne,ne,ne").distance(from: .zero),       3)
    XCTAssertEqual(HexGrid.walk(path: "ne,ne,sw,sw").distance(from: .zero),    0)
    XCTAssertEqual(HexGrid.walk(path: "ne,ne,s,s").distance(from: .zero),      2)
    XCTAssertEqual(HexGrid.walk(path: "se,sw,se,sw,sw").distance(from: .zero), 3)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension HexGridTests {
  static var allTests: [(String, (HexGridTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
