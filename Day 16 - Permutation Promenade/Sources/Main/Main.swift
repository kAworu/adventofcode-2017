import PermutationPromenade

let puzzle  = readLine()! // Acquire puzzle input from stdin.
let dancers = PermutationPromenade(count: 16)
print("The programs after finishing their dance once are \(dancers ♫ puzzle),")
print("and after a billion times \(dancers ♫ puzzle ♯ 1_000_000_000).")
