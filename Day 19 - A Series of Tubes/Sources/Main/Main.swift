import Tubes

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle  = get_puzzle()
let path    = Tubes.RoutingDiagram(puzzle).path()
let letters = path.map { "\($0)" }
print("the packet has collected the letters \(letters.joined()),")
print("and has done \(path.count) steps.")
