import XCTest
@testable import FractalArt

class FractalArtTests: XCTestCase {

  func testPartOne() {
    let rules = [
      "../.# => ##./#../...",
      ".#./..#/### => #..#/..../..../#..#",
    ]
    let fractal = FractalArt(rules: rules)!
    var grid = fractal.grid
    XCTAssertEqual("\(grid)", ".#./..#/###")
    grid = fractal.enhance(times: 1)
    XCTAssertEqual("\(grid)", "#..#/..../..../#..#")
    grid = fractal.enhance(times: 2)
    XCTAssertEqual("\(grid)", "##.##./#..#../....../##.##./#..#../......")
  }
}

#if os(Linux)
extension FractalArtTests {
  static var allTests: [(String, (FractalArtTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
    ]
  }
}
#endif
