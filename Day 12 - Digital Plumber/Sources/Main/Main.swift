import PipeNetwork

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle  = get_puzzle()
let network = PipeNetwork(puzzle)!
let p0      = network[program: 0]!
print("There are \(p0.group().count) programs in the group of program ID 0,")
print("and \(network.groups().count) groups in total.")
