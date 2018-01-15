import Spinlock

let puzzle = Int(readLine()!)! // Acquire puzzle input from stdin.
let lock   = Spinlock(step: puzzle)
lock.spin(count: 2017)
print("The value next to 2017 is \(lock.next_to(2017)!) after 2017 spins,")
let angry = FakeSpinlock(step: puzzle)
angry.spin(count: 50_000_000)
print("and the value next to 0 is \(angry.next_to_zero!) after fifty million spins.")
