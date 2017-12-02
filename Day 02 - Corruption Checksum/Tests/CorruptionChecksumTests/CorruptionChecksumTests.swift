import XCTest
@testable import SpreadSheet

#if os(Linux)
extension CorruptionChecksumTests {
  static var allTests: [(String, (CorruptionChecksumTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
    ]
  }
}
#endif

class CorruptionChecksumTests: XCTestCase {

  func testPartOne() {
    XCTAssertEqual(SpreadSheet("5 1 9 5").checksum, 8)
    XCTAssertEqual(SpreadSheet("7 5 3").checksum,   4)
    XCTAssertEqual(SpreadSheet("2 4 6 8").checksum, 6)
    XCTAssertEqual(SpreadSheet("""
    5 1 9 5
    7 5 3
    2 4 6 8
    """).checksum, 18)
  }
}
