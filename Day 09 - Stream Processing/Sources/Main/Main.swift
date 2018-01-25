import StreamProcessing

let puzzle = readLine()! // Acquire puzzle input from stdin.
let stream = StreamProcessing.parse(puzzle)!
print("The total score is \(stream.score()),")
print("and there are \(stream.garbage_count()) chracters within the garbage.")
