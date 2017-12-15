import MemoryReallocation

// Acquire puzzle input from stdin.
let puzzle   = readLine()!.split { $0 == "\t" }.map { Int($0)! }
let debugger = MemoryReallocation(puzzle)
let cycles   = debugger.debug()
print("\(cycles.before_looping) redistribution cycles must be completed before the infinite loop,")
print("and the loop itself has \(cycles.loop) cycles.")
