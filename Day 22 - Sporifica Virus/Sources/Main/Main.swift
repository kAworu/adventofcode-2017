import SporificaVirus

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle  = get_puzzle()
let cluster = SporificaVirus(grid: puzzle)!
var infection_count = 0
cluster.on(.infected) { _ in
  infection_count += 1
}
cluster.burst(times: 10_000)
print("After a total of 10000 bursts of activity, \(infection_count) bursts will have caused an infection.")
