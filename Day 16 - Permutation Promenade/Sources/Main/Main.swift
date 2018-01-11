import PermutationPromenade

let puzzle   = readLine()! // Acquire puzzle input from stdin.
let programs = PermutationPromenade(count: 16)
programs.dance(tune: puzzle)
print("The programs after finishing their dance are \(programs).")
