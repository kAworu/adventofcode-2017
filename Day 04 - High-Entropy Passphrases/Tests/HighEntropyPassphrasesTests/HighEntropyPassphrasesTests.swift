import XCTest
@testable import HighEntropyPassphrases

class HighEntropyPassphrasesTests: XCTestCase {

  func testPartOne() {
    XCTAssertFalse(HighEntropyPassphrases("aa bb cc dd ee").has_duplicate_word)
    XCTAssert(HighEntropyPassphrases("aa bb cc dd aa").has_duplicate_word)
    XCTAssertFalse(HighEntropyPassphrases("aa bb cc dd aaa").has_duplicate_word)
  }

  func testPartTwo() {
    XCTAssertFalse(HighEntropyPassphrases("abcde fghij").has_anagram)
    XCTAssert(HighEntropyPassphrases("abcde xyz ecdab").has_anagram)
    XCTAssertFalse(HighEntropyPassphrases("a ab abc abd abf abj").has_anagram)
    XCTAssertFalse(HighEntropyPassphrases("iiii oiii ooii oooi oooo").has_anagram)
    XCTAssert(HighEntropyPassphrases("oiii ioii iioi iiio").has_anagram)
  }
}

#if os(Linux)
extension HighEntropyPassphrasesTests {
  static var allTests: [(String, (HighEntropyPassphrasesTests) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
