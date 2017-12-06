public class HighEntropyPassphrases {
  let passphrase: [String]

  public init (_ passphrase: String) {
    self.passphrase = passphrase.split(separator: " ").map(String.init)
  }

  // true if this passphrase contains no duplicate words, false otherwise.
  public var valid: Bool {
    var seen: Set<String> = []
    for word in passphrase {
      if seen.contains(word) {
        return false
      }
      seen.insert(word)
    }
    return true
  }
}
