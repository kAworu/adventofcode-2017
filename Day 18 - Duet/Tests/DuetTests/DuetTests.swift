import XCTest
@testable import Duet

class DuetTests: XCTestCase {

  func testPartOne() {
    let program = Duet.Assembly(.v1, """
      set a 1
      add a 2
      mul a a
      mod a 5
      snd a
      set a 0
      rcv a
      jgz a -1
      set a 1
      jgz a -2
    """)!
    let processor = Duet.Processor(program: program)
    var called = 0
    var sound: Int? = nil
    processor.on(.recover) {
      sound = $0
      called += 1
      return .stop
    }
    processor.run()
    XCTAssertEqual(sound, 4)
    XCTAssertEqual(called, 1)
  }

  func testPartTwo() {
    let program = Duet.Assembly(.v2, """
      snd 1
      snd 2
      snd p
      rcv a
      rcv b
      rcv c
      rcv d
    """)!
    let p0 = Duet.Processor(id: 0, program: program)
    let p1 = Duet.Processor(id: 1, program: program)
    var messages_sent_by_p0: [Int] = []
    var messages_sent_by_p1: [Int] = []
    p0.on(.send) {
      messages_sent_by_p0.append($0!)
      return .proceed
    }
    p1.on(.send) {
      messages_sent_by_p1.append($0!)
      return .proceed
    }
    Duet.run_in_duet(p0, and: p1)
    XCTAssertEqual(messages_sent_by_p0, [1, 2, 0])
    XCTAssertEqual(messages_sent_by_p1, [1, 2, 1])
    XCTAssertEqual(p0.registers, ["a": 1, "b": 2, "c": 1, "p": 0])
    XCTAssertEqual(p1.registers, ["a": 1, "b": 2, "c": 0, "p": 1])
  }
}

#if os(Linux)
extension DuetTests {
  static var allTests: [(String, (DuetTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
