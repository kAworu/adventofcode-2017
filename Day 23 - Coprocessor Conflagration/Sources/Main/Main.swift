import CoprocessorConflagration

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle()

let program   = CoprocessorConflagration.Assembly(puzzle)!
let processor = CoprocessorConflagration.CoProcessor(program: program)
processor.run()
let mul_count = processor.usage["mul"]!
print("The mul instruction is invoked \(mul_count) times.")
