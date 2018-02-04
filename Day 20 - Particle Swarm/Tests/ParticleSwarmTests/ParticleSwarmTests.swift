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
    let swarm = ParticleSwarm([
      "p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>",
      "p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>",
      "p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>",
      "p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>",
    ])!
    let collisions = swarm.collisions()
    XCTAssertEqual(collisions.count, 1)
    XCTAssertEqual(collisions[0].particles.map { $0.id }.sorted(), [0, 1, 2])
    XCTAssertEqual(collisions[0].time, 2)
    XCTAssertEqual(collisions[0].position, .origin)
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
