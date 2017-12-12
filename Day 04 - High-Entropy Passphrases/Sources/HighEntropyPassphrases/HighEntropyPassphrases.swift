public class HighEntropyPassphrases {
  let passphrase: [String]

  public init (_ passphrase: String) {
    self.passphrase = passphrase.split(separator: " ").map(String.init)
  }

  // NOTE: part one
  // Returns false if this passphrase contains no duplicate words,
  // true otherwise.
  public var has_duplicate_word: Bool {
    return has_duplicate { $0 }
  }

  // NOTE: part two
  // Returns false if this passphrase contains no two words that are anagrams
  // of each other, true otherwise.
  public var has_anagram: Bool {
    return has_duplicate { CountedChars($0).description }
  }

  // Returns true if all words in our passphrase have a different image through
  // `f', false otherwise.
  // NOTE: No guarantee that `f' will be invoked with every words.
  internal func has_duplicate(_ f: (String) -> String) -> Bool {
    var seen: Set<String> = []
    for word in passphrase {
      let entry = f(word)
      if seen.contains(entry) {
        return true
      }
      seen.insert(entry)
    }
    return false
  }
}

// Helper class for part 2, anagrams will have the same CountedChars string
// description.
class CountedChars {
  let counts: [Character: Int]

  init(_ word: String) {
      var counts: [Character: Int] = [:]
      for c in word {
        counts[c, default: 0] += 1
      }
      self.counts = counts
  }
}

extension CountedChars: CustomStringConvertible {
  // build a description string with each character prefixed by its count,
  // sorted in alphabetical order.
  var description: String {
    return Array(counts.keys).sorted(by: <).map { c in
      "\(counts[c]!)\(c)"
    }.joined()
  }
}
