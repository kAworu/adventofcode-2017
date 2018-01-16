import Duet

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle       = get_puzzle()
let instructions = Duet.Assembly(puzzle)!
let processor    = Duet.Processor(rcv: {
  print("the most recently played sound the first time a rcv instruction is executed is \($0!)")
  return false
})
processor.execute(instructions)
