import HaltingProblem

// Acquire puzzle input from stdin.
func get_puzzle() -> String {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input.joined(separator: "\n")
}

let puzzle  = get_puzzle()
let machine = try HaltingProblem(blueprint: puzzle)
let tape    = machine.run()
print("The diagnostic checksum is \(tape.checksum()).")
