import HexGrid

let puzzle = readLine()! // Acquire puzzle input from stdin.
let path   = HexGrid.walk(puzzle)
print("the fewest number of steps required to reach the child process is \(path.final_distance()),")
print("and the furthest he ever got was \(path.furthest_distance()) steps away.")
