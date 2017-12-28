import MemoryReallocation

// Acquire puzzle input from stdin.
let puzzle   = readLine()!.split(separator: "\t").map { Int($0)! }
let debugger = MemoryReallocation(puzzle)
let cycles   = debugger.realloc()
print("\(cycles.before_looping) redistribution cycles must be completed before the infinite loop,")
print("and the loop itself has \(cycles.loop) cycles.")
