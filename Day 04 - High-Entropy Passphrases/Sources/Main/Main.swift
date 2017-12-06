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
let nvalid = passphrases.filter({ $0.valid }).count
print("There are \(nvalid) valid passphrases")
