import TwistyTrampolinesMaze

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle().map { Int($0)! }
let maze   = TwistyTrampolinesMaze(puzzle)
print("The exit is reached in \(maze.strange_jumps_exit) steps,")
print("and \(maze.stranger_jumps_exit) with the new rules.")
