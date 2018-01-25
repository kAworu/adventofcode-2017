import XCTest
@testable import HexGrid

class HexGridTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(HexGrid.walk("ne,ne,ne").final_distance(),       3)
    XCTAssertEqual(HexGrid.walk("ne,ne,sw,sw").final_distance(),    0)
    XCTAssertEqual(HexGrid.walk("ne,ne,s,s").final_distance(),      2)
    XCTAssertEqual(HexGrid.walk("se,sw,se,sw,sw").final_distance(), 3)
  }

  func testPartTwo() {
    XCTAssertEqual(HexGrid.walk("ne,ne,ne").furthest_distance(),       3)
    XCTAssertEqual(HexGrid.walk("ne,ne,sw,sw").furthest_distance(),    2)
    XCTAssertEqual(HexGrid.walk("ne,ne,s,s").furthest_distance(),      2)
    XCTAssertEqual(HexGrid.walk("se,sw,se,sw,sw").furthest_distance(), 3)
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
