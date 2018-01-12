import Spinlock

let puzzle = Int(readLine()!)! // Acquire puzzle input from stdin.
let lock   = Spinlock(step: puzzle)
lock.spin(count: 2017)
print("The value after 2017 spins is \(lock[1]).")
