import HighEntropyPassphrases

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let passphrases = get_puzzle().map(HighEntropyPassphrases.init)
let without_dup     = passphrases.filter { !$0.has_duplicate_word() }
let without_anagram = passphrases.filter { !$0.has_anagram() }
print("There are \(without_dup.count) valid passphrases under the new policy,")
print("and \(without_anagram.count) valid passphrases under the second new policy.")
