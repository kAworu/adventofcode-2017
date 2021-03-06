import XCTest
@testable import SpreadSheet

class CorruptionChecksumTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(SpreadSheet.Row("5 1 9 5").checksum(), 8)
    XCTAssertEqual(SpreadSheet.Row("7 5 3").checksum(),   4)
    XCTAssertEqual(SpreadSheet.Row("2 4 6 8").checksum(), 6)
    XCTAssertEqual(SpreadSheet("""
    5 1 9 5
    7 5 3
    2 4 6 8
    """).checksum(), 18)
  }

  func testPartTwo() {
    XCTAssertEqual(SpreadSheet.Row("5 9 2 8").division(), 4)
    XCTAssertEqual(SpreadSheet.Row("9 4 7 3").division(), 3)
    XCTAssertEqual(SpreadSheet.Row("3 8 6 5").division(), 2)
    XCTAssertEqual(SpreadSheet("""
    5 9 2 8
    9 4 7 3
    3 8 6 5
    """).division(), 9)
  }
}

#if os(Linux)
extension CorruptionChecksumTests {
  static var allTests: [(String, (CorruptionChecksumTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif // os(Linux)
