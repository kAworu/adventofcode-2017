import ParticleSwarm

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle()
let swarm  = ParticleSwarm(puzzle)!
let closest = swarm.closest_to_origin_in_the_long_run()!
print("The particle \(closest.id) will stay closest to <0,0,0> in the long run,")
let destroyed = swarm.collisions().reduce(0) { $0 + $1.particles.count }
print("and \(swarm.count - destroyed) particles are left after all collisions are resolved.")
