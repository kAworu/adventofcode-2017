import XCTest
@testable import PacketScanners

class PacketScannersTests: XCTestCase {
  static let PUZZLE = """
    0: 3
    1: 2
    4: 4
    6: 4
  """

  func testPartOne() {
    let firewall = PacketScanners(PacketScannersTests.PUZZLE)
    XCTAssertEqual(firewall.trip_severity(delay:  0), 24)
    XCTAssertEqual(firewall.trip_severity(delay: 10),  0)
  }

  func testPartTwo() {
    let firewall = PacketScanners(PacketScannersTests.PUZZLE)
    XCTAssertEqual(firewall.safe_trip_delay, 10)
  }
}

#if os(Linux)
extension PacketScannersTests {
  static var allTests: [(String, (PacketScannersTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
