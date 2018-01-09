import DuelingGenerators
import Regex


// Acquire puzzle input from stdin.
func get_puzzle() -> (A: Int, B: Int)? {
  let re = Regex("Generator (A|B) starts with ([0-9]+)")
  var (A, B) = (0, 0)
  while let line = readLine() {
    guard let match = re.firstMatch(in: line) else { return nil }
    let n = Int(match.captures[1]!)!
    if match.captures[0]! == "A" {
      A = n
    } else {
      B = n
    }
  }
  return (A: A, B: B)
}

let puzzle = get_puzzle()!
let generators = DuelingGenerators(A: puzzle.A, B: puzzle.B)
print("After 40 million pairs, the judge's final count is \(generators.final_count()).")
