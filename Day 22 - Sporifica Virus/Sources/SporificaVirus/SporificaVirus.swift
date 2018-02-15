// The local grid computing cluster.
public class SporificaVirus {
  // Function type used as status change callback by the infection burst
  // process.
  public typealias Callback = (Grid.Point) -> ()

  var grid: Grid
  var virus: Virus
  var listeners: [Grid.Status: Callback] = [:]

  // Create a computing cluster given a string description of the grid and its
  // virus generation. Returns nil if parsing the grid failed.
  public convenience init?(grid s: String, generation: Virus.Generation) {
    let xs = s.split(separator: "\n").map(String.init)
    self.init(grid: xs, generation: generation)
  }

  // Create a computing cluster given a string description of the grid and its
  // virus generation. Returns nil if parsing the grid failed.
  public init?(grid xs: [String], generation: Virus.Generation) {
    guard let grid = Grid(xs) else { return nil }
    self.grid  = grid
    self.virus = Virus(heading: .up, position: .origin, generation: generation)
  }

  // Register the given callback function to be called when the provided status
  // change arise. Returns the callback previously setup for the event if any.
  @discardableResult
  public func on(_ event: Grid.Status, callback: @escaping Callback) -> Callback? {
      let old = listeners[event]
      listeners[event] = callback
      return old
  }

  // Make the virus burst a given number of time in this computing cluster.
  public func burst(times: Int = 1) {
    for _ in 0..<times {
      let current = virus.position // the current node
      let status = virus.burst(in: grid)
      // Notify listener if any.
      if let callback = listeners[status] {
        callback(current)
      }
    }
  }

  // Returns a description of the grid with the virus frop the top-left (tl)
  // point to the bottom-right (br) point included.
  public func draw(_ tl: Grid.Point, _ br: Grid.Point) -> String {
    // Helper giving the prefix to display just before the given position.
    func separator(_ p: Grid.Point) -> String {
      switch p {
        case _ where p.x == tl.x:    return ""
        case virus.position:         return "["
        case virus.position[.right]: return "]"
        default:                     return " "
      }
    }
    var description = ""
    for y in tl.y...br.y {
      for x in tl.x...br.x {
        let position = Grid.Point(x: x, y: y)
        description.append(separator(position))
        description.append(grid[position].rawValue)
      }
      if y != br.y { // don't finish with a newline.
        description.append("\n")
      }
    }
    return description
  }
}
