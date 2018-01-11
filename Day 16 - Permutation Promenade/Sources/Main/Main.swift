import PermutationPromenade

let puzzle  = readLine()! // Acquire puzzle input from stdin.
let dancers = PermutationPromenade(count: 16)
dancers ♫ puzzle
print("The programs after finishing their dance once are \(dancers),")
dancers ♫ puzzle ♯ 999_999_999
print("and after a billion times \(dancers).")
