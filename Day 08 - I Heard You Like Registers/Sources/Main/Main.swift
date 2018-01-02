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
let cpu    = LikableRegisters.Processor()
let all_time_max = LikableRegisters(puzzle)!.compute(on: cpu)!
let final_max    = cpu.max!
print("The register \(final_max.key) has the largest value of \(final_max.value),")
print("and the register \(all_time_max.key) did hold \(all_time_max.value) at some point during the program execution.")
