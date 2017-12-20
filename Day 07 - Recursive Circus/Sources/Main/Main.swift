import RecursiveCircus

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle()
let tower  = RecursiveCircus(puzzle)!
print("The bottom program is \(tower.bottom_program!).")
