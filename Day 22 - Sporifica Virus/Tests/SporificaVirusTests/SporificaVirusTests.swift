import XCTest
@testable import SporificaVirus

class SporificaVirusTests: XCTestCase {

  func testPartOne() {
    let puzzle = """
    ..#
    #..
    ...
    """
    let (top_left, bottom_right) = ((x: -4, y: -4), (x: 4, y: 3))
    var burst_count     = 0
    var infection_count = 0

    let cluster = SporificaVirus(grid: puzzle)!
    cluster.on(.infected) { _ in
      burst_count += 1
      infection_count += 1
    }
    cluster.on(.clean) { _ in
      burst_count += 1
    }

    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . # . . .
    . . . #[.]. . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)

    cluster.burst()
    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . # . . .
    . . .[#]# . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)

    cluster.burst()
    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . .[.]. # . . .
    . . . . # . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)

    cluster.burst(times: 4)
    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . #[#]. # . . .
    . . # # # . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)

    cluster.burst()
    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . # .[.]# . . .
    . . # # # . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)
    XCTAssertEqual(burst_count, 7)
    XCTAssertEqual(infection_count, 5)

    cluster.burst(times: 70 - burst_count)
    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . # # . .
    . . . . # . . # .
    . . . # . . . . #
    . . # . #[.]. . #
    . . # . # . . # .
    . . . . . # # . .
    . . . . . . . . .
    . . . . . . . . .
    """)
    XCTAssertEqual(infection_count, 41)

    cluster.burst(times: 10_000 - burst_count)
    XCTAssertEqual(infection_count, 5587)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension SporificaVirusTests {
  static var allTests: [(String, (SporificaVirusTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
