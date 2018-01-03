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
print("The trip severity is \(firewall.trip_severity).")
