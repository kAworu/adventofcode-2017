import MemoryReallocation

// Acquire puzzle input from stdin.
let puzzle = readLine()!.split { $0 == "\t" }.map { Int($0)! }
let debugger = MemoryReallocation(puzzle)
print("\(debugger.redistribution_cycles_count) redistribution cycles must be completed before the infinite loop.")
