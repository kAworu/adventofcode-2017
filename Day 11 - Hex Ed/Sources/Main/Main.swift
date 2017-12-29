import HexGrid

let puzzle   = readLine()! // Acquire puzzle input from stdin.
let position = HexGrid.walk(path: puzzle)
let distance = position.distance(from: .zero)
print("the fewest number of steps required to reach the child process is \(distance).")
