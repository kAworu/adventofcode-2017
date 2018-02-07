import FractalArt

// Acquire puzzle input from stdin.
func get_puzzle() -> [String] {
  var input: [String] = []
  while let line = readLine() {
    input.append(line)
  }
  return input
}

let puzzle = get_puzzle()
let fractal = FractalArt(rules: puzzle)!

var grid = fractal.enhance(times: 5)
var pixels_lit_count = grid.pixels.filter { $0 == .on }.count
print("There are \(pixels_lit_count) pixels on after 5 enhancement iterations,")

grid = fractal.enhance(times: 18)
pixels_lit_count = grid.pixels.filter { $0 == .on }.count
print("and \(pixels_lit_count) pixels on after 18 enhancement iterations.")
