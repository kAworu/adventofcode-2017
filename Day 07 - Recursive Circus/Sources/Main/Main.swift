import RecursiveCircus

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle()
let tower  = RecursiveCircus(puzzle)!
let bottom = tower.bottom_program!
print("The bottom program is \(bottom),")
do {
  let tower_weight = try bottom.total_weight()
  print("and the tower's weight is \(tower_weight).")
} catch let err as InvalidWeightError {
  print("and \(err.culprit) corrected weight is \(err.corrected_weight).")
}
