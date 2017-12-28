import KnotHash

let puzzle  = readLine()! // Acquire puzzle input from stdin.
let hasher  = KnotHash()
let lengths = puzzle.split(separator: ",").map { UInt8($0)! }
hasher.update(lengths)
let (first, second) = (UInt32(hasher[0]!), UInt32(hasher[1]!))
print("\(first) * \(second) = \(first * second),")
let hash = KnotHash.hash(puzzle)
print("and the Knot hash of the input is \(hash).")
