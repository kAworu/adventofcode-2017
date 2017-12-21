import LikableRegisters

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle()
let cpu    = Processor()
LikableRegisters(puzzle)!.compute(on: cpu)
if let max = cpu.max {
  print("The register \(max.key) has the largest value of \(max.value).")
} else {
  print("Something went wrong.")
}
