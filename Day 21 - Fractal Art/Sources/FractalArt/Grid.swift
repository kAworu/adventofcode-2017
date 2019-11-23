extension FractalArt {
  // Represents a square grid of pixels.
  public struct Grid: Hashable, CustomStringConvertible {
    // Hackerzz
    public static let glider = Grid(".#./..#/###")!

    // Represents a pixel from the grid.
    public enum Pixel: Character {
      case on  = "#"
      case off = "."
    }

    // Returns true if the two given grid are the same, false otherwise.
    public static func == (lhs: Grid, rhs: Grid) -> Bool {
      return lhs.size == rhs.size && lhs.pixels == rhs.pixels
    }

    public let size: Int
    public let pixels: [Pixel]

    // Create a new grid from a description string. Both newline (\n) and
    // slash (/) are accepted as separator. Returns nil on parsing failure.
    init?(_ s: String) {
      var pixels: [Pixel] = []
      var size = 1
      // XXX: this heuristic will accept suspicious descriptions like
      // ".#...####//" but meh.
      for c in s {
        if let pixel = Pixel(rawValue: c) {
          pixels.append(pixel)
        } else if c == "/" || c == "\n" {
          size += 1
        } else {
          return nil
        }
      }
      self.init(size: size, pixels: pixels)
    }

    // Create a grid from many other grids. The given size is the size of the
    // array of grid. Returns nil unless all the grids have the same size.
    init?(size: Int, squares: [Grid]) {
      guard squares.count == (size * size) else { return nil }
      guard size > 0 else { return nil }
      let sqsize = squares.first!.size
      if squares.contains(where: { $0.size != sqsize }) {
        return nil
      }
      var pixels: [Pixel] = []
      for y in 0..<size {
        for sqy in 0..<sqsize {
          for x in 0..<size {
            let square = squares[x + y * size]
            for sqx in 0..<sqsize {
              pixels.append(square[sqx, sqy])
            }
          }
        }
      }
      self.init(size: size * sqsize, pixels: pixels)
    }

    // Create a grid given its size and its pixel. Returns nil if the size
    // doesn't match the pixel count.
    init?(size: Int, pixels: [Pixel]) {
      guard pixels.count == (size * size) else { return nil }
      guard size > 0 else { return nil }
      self.size = size
      self.pixels = pixels
    }

    // Returns this grid enhanced by the given rules.
    func enhanced(by rules: [Grid: Grid]) -> Grid {
      let step = (size % 2 == 0 ? 2 : 3)
      // Split the grid into squares of size step.
      var squares: [Grid] = []
      for tly in stride(from: 0, to: size, by: step) {
        let bry = tly + step - 1
        for tlx in stride(from: 0, to: size, by: step) {
          let brx = tlx + step - 1
          let square = self[(tlx, tly), (brx, bry)]!
          squares.append(square)
        }
      }
      // Now enhance each square.
      let enhanced = squares.map { rules[$0]! }
      return Grid(size: size / step, squares: enhanced)!
    }

    // Returns all the transformations (rotations and flips) of this grid.
    func transformations() -> Set<Grid> {
      var variations: Set<Grid> = []
      var grid = self
      for _ in 1...4 {
        grid = grid.rotated()
        variations.insert(grid)
        variations.insert(grid.flipped())
      }
      return variations
    }

    // Return this grid rotated once clockwise.
    func rotated() -> Grid {
      var pixels: [Pixel] = []
      for x in 0..<size {
        for y in (0..<size).reversed() {
          pixels.append(self[x, y])
        }
      }
      return Grid(size: size, pixels: pixels)!
    }

    // Return a flipped version of this grid.
    func flipped() -> Grid {
      var pixels: [Pixel] = []
      for y in 0..<size {
        for x in (0..<size).reversed() {
          pixels.append(self[x, y])
        }
      }
      return Grid(size: size, pixels: pixels)!
    }

    // Get the pixel at the given coordinate.
    subscript(x: Int, y: Int) -> Pixel {
      return pixels[x + y * size]
    }

    // Get the square subgrid delimited by the top-left (tl) position and the
    // bottom-right (br) position included. Returns nil if any x or y is out of
    // bound or if the positions don't define a square.
    subscript(tl: (x: Int, y: Int), br: (x: Int, y: Int)) -> Grid? {
      guard (0..<size).contains(tl.x) else { return nil }
      guard (0..<size).contains(tl.y) else { return nil }
      guard (0..<size).contains(br.x) else { return nil }
      guard (0..<size).contains(br.y) else { return nil }
      var pixels: [Pixel] = []
      for y in tl.y...br.y {
        for x in tl.x...br.x {
          pixels.append(self[x, y])
        }
      }
      return Grid(size: br.x - tl.x + 1, pixels: pixels)
    }

    // Conform to Hashable.
    public func hash(into hasher: inout Hasher) {
      // NOTE: We use the corners and the center pixels plus the size to build
      // a hash value. Using only the size is terrible given that we use it for
      // 2x2 and 3x3 grids and using all the pixels is too slow.
      hasher.combine(self[0, 0])               // top-left
      hasher.combine(self[size - 1, 0])        // top-right
      hasher.combine(self[size - 1, size - 1]) // bottom-right
      hasher.combine(self[0, size - 1])        // bottom-left
      hasher.combine(self[size / 2, size / 2]) // middle
    }

    // Returns a string description of this grid, using slashes (/) as
    // separator.
    public var description: String {
      let step = size
      let limit = pixels.count
      let lines: [String] = stride(from: 0, to: limit, by: step).map { start in
        let stop = start + step
        return String(self.pixels[start..<stop].map { $0.rawValue })
      }
      return lines.joined(separator: "/")
    }
  }
}
