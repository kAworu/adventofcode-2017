import XCTest
@testable import SporificaVirus

class SporificaVirusTests: XCTestCase {
  static let PUZZLE = """
  ..#
  #..
  ...
  """

  func testPartOne() {
    let top_left     = SporificaVirus.Grid.Point(x: -4, y: -4)
    let bottom_right = SporificaVirus.Grid.Point(x:  4, y:  3)
    var burst_count     = 0
    var infection_count = 0

    let cluster = SporificaVirus(grid: SporificaVirusTests.PUZZLE, generation: .first)!
    cluster.on(.infected) { _ in
      infection_count += 1
      burst_count     += 1
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
    let top_left     = SporificaVirus.Grid.Point(x: -4, y: -4)
    let bottom_right = SporificaVirus.Grid.Point(x:  4, y:  3)
    var burst_count     = 0
    var infection_count = 0

    let cluster = SporificaVirus(grid: SporificaVirusTests.PUZZLE, generation: .evolved)!
    cluster.on(.infected) { _ in
      infection_count += 1
      burst_count     += 1
    }
    cluster.on(.clean)    { _ in burst_count += 1 }
    cluster.on(.weakened) { _ in burst_count += 1 }
    cluster.on(.flagged)  { _ in burst_count += 1 }

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
    . . .[#]W . . . .
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
    . . . F W . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)

    cluster.burst(times: 3)
    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . W W . # . . .
    . . W[F]W . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)

    cluster.burst()
    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . W W . # . . .
    . .[W]. W . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)

    cluster.burst()
    XCTAssertEqual(cluster.draw(top_left, bottom_right), """
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . W W . # . . .
    .[.]# . W . . . .
    . . . . . . . . .
    . . . . . . . . .
    . . . . . . . . .
    """)

    cluster.burst(times: 100 - burst_count)
    XCTAssertEqual(infection_count, 26)

    cluster.burst(times: 10_000_000 - burst_count)
    XCTAssertEqual(infection_count, 2511944)
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
