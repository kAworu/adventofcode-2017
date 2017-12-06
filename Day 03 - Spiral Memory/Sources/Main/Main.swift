import SpiralMemory

let puzzle = readLine()! // Acquire puzzle input from stdin.
let spiral = SpiralMemory(Int(puzzle)!)
print("\(spiral.snake_distance) step(s) are required,")
print("and the first value written larger than \(puzzle) is \(spiral.stress_test_gt).")
