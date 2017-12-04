import SpiralMemory

let puzzle = readLine()! // Acquire puzzle input from stdin.
print("\(SpiralMemory(Int(puzzle)!).snake_distance) step(s) are required.")
