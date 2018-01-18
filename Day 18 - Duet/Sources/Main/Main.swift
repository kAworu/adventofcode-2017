import Duet

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle()

// part 1
let program   = Duet.Assembly(.v1, puzzle)!
let processor = Duet.Processor(program: program)
processor.on(.recover) {
  print("The most recently played sound the first time a rcv instruction is executed is \($0!),")
  return .stop
}
processor.run()

// part 2
let program_v2 = Duet.Assembly(.v2, puzzle)!
let p0 = Duet.Processor(id: 0, program: program_v2)
let p1 = Duet.Processor(id: 1, program: program_v2)
var messages_sent_by_p1: [Int] = []
p1.on(.send) {
  messages_sent_by_p1.append($0!)
  return .proceed
}
Duet.run_in_duet(p0, and: p1)
print("and once obht programs have terminated the program 1 sent \(messages_sent_by_p1.count) values.")
