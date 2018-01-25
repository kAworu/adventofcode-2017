import XCTest
@testable import ParticleSwarm

class ParticleSwarmTests: XCTestCase {

  func testPartOne() {
    let swarm = ParticleSwarm([
      "p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>",
      "p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>",
    ])!
    XCTAssertEqual(swarm.closest_to_origin_in_the_long_run()!.id, 0)
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension ParticleSwarmTests {
  static var allTests: [(String, (ParticleSwarmTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
