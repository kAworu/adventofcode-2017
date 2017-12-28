import KnotHash

let puzzle = readLine()! // Acquire puzzle input from stdin.
let hasher = KnotHash(0..<256)
print("The hash is \(hasher.hash(lengths: puzzle)).")
