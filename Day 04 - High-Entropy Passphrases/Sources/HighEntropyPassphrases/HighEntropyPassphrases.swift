// Passphrase security checker.
public class HighEntropyPassphrases {
  let words: [String]

  // Create a new checker for the given passphrase.
  public init (_ passphrase: String) {
    self.words = passphrase.split(separator: " ").map(String.init)
  }

  // Returns false if this passphrase contains no duplicate words,
  // true otherwise.
  public var has_duplicate_word: Bool {
    return has_duplicate { $0 }
  }

  // Returns false if this passphrase contains no two words that are anagrams
  // of each other, true otherwise.
  public var has_anagram: Bool {
    return has_duplicate { CountedChars($0).description }
  }

  // Returns true if all words in our passphrase have a different image through
  // `f', false otherwise.
  // NOTE: No guarantee that `f' will be invoked with every passphrase's word.
  internal func has_duplicate(_ f: (String) -> String) -> Bool {
    var seen: Set<String> = []
    for word in words {
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
    return Array(counts.keys).sorted().map { c in
      "\(counts[c]!)\(c)"
    }.joined()
  }
}
