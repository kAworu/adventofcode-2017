import PacketScanners

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle   = get_puzzle()
let firewall = PacketScanners(puzzle)
print("When leaving immediatley the trip severity is \(firewall.trip_severity(delay: 0)),")
print("and the smallest delay required to travel without being caught is \(firewall.safe_trip_delay) picoseconds.")
