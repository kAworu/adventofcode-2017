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
print("The mul instruction is invoked \(mul_count) times,")

// The second part need to optimize the assembly code by hand (see the
// analysis/ directory for steps). The last step show that the register `h`
// value is set to the count of composite (i.e. non-prime) numbers in the
// firsts 1001 numbers starting from 93 * 100 + 100000 by steps of 17.

// Returns true if n is prime, false otherwise.
func is_prime(_ n: Int) -> Bool {
  // Naive algorithm checking each possible divisor from 2 to sqrt(n).
  let sqrt = Int(Double(n).squareRoot())
  return n > 1 && !(2...sqrt).contains { n % $0 == 0 }
}

let step = 17
// When a != 0 we have this preamble to setup b (the starting number) and c
// (the limit).
let b = 93 * 100 + 100000
let c = b + step * 1001

// Now compute h using the is_prime() function.
let h = stride(from: b, to: c, by: step).reduce(0) { acc, i in
  acc + (is_prime(i) ? 0 : 1)
}

// We're done.
print("and the value of the register h is \(h) if the program were to run to completion when the debug switch is flipped.")
