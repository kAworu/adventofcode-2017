import ElectromagneticMoat

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle()
let moat = ElectromagneticMoat(components: puzzle)!
let (strongest, longest) = moat.strongest_and_longest()
print("The strength of the strongest bridge is \(strongest.strength),")
print("and the strength of the longest bridge is \(longest.strength).")
