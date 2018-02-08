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

var cluster = SporificaVirus(grid: puzzle, generation: .first)!
var infection_count = 0
cluster.on(.infected) { _ in infection_count += 1 }
cluster.burst(times: 10_000)
print("After a total of 10000 bursts of activity, \(infection_count) bursts will have caused an infection.")

cluster = SporificaVirus(grid: puzzle, generation: .evolved)!
infection_count = 0
cluster.on(.infected) { _ in infection_count += 1 }
cluster.burst(times: 10_000_000)
print("And after a total of 10000000 bursts of activity, \(infection_count) bursts will have caused an infection from the evolved version of the virus.")
