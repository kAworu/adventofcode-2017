// infection operator (skull and crossbones),
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Health_and_safety
infix operator ☠  : AdditionPrecedence

// The local grid computing cluster.
public class SporificaVirus {
  // Function type used as status change callback by the infection burst
  // process.
  public typealias Callback = (Point) -> ()

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
  public func draw(_ tl: Point, _ br: Point) -> String {
    // Helper giving the prefix to display just before the given position.
    func separator(_ p: Point) -> String {
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
        let position = Point(x: x, y: y)
        description.append(separator(position))
        description.append(grid[position].rawValue)
      }
      if y != br.y { // don't finish with a newline.
        description.append("\n")
      }
    }
    return description
  }

  // Teh Sporifica Virus.
  public class Virus {
    // The virus generation.
    public enum Generation {
      case first, evolved

      // Returns the new status of a node in the initial given status after the
      // infection from a virus of this generation.
      static func ☠  (agent: Generation, victim: Grid.Status) -> Grid.Status {
        switch (agent, victim) {
          case (.first, .infected):   return .clean
          case (.first, _):           return .infected
          case (.evolved, .clean):    return .weakened
          case (.evolved, .weakened): return .infected
          case (.evolved, .infected): return .flagged
          case (.evolved, .flagged):  return .clean
        }
      }
    }

    var heading: Heading
    var position: Point
    let generation: Generation

    // Create a virus.
    init(heading: Heading, position: Point, generation: Generation) {
      self.heading    = heading
      self.position   = position
      self.generation = generation
    }

    // Return the new status for the current position.
    func burst(in grid: Grid) -> Grid.Status {
      var status = grid[position] // the current node status
      // Virus action depending on the current node status.
      switch status {
        case .clean:
          heading = heading.left
        case .infected:
          heading = heading.right
        case .flagged:
          heading = heading.opposite
        case .weakened: // do not turn
          break
      }
      // Update the current node status.
      status = self.generation ☠  status
      grid[position] = status
      // Finally, the virus move forward.
      position = position[heading]
      // We're done, return the new status.
      return status
    }
  }

  // Represents the nodes states in the grid.
  public class Grid {
    // Represents a node status.
    public enum Status: Character {
      case infected = "#"
      case clean    = "."
      case weakened = "W"
      case flagged  = "F"
    }

    var nodes: [Point: Status]

    // Create a grid given a string description. Returns nil if parsing failed.
    // Note that the origin point will be the center of the grid.
    init?(_ xs: [String]) {
      guard xs.count > 0 else { return nil }
      let half = xs.first!.count / 2
      // ensure that all rows are of the same size and have an odd column
      // count.
      guard !xs.contains(where: { $0.count != 1 + half * 2 }) else { return nil }
      var nodes: [Point: Status] = [:]
      for (y, row) in xs.enumerated() {
        for (x, c) in row.enumerated() {
          guard let status = Status(rawValue: c) else { return nil }
          let position = Point(x: x - half, y: y - half)
          nodes[position] = status
        }
      }
      self.nodes = nodes
    }

    // Returns or set the status of the node at the given position.
    subscript(_ position: Point) -> Status {
      get {
        return nodes[position] ?? .clean
      }
      set(newValue) {
        // NOTE: we could just nodes.removeValue(forKey: position) when
        // newValue == .clean and insert / update otherwise, but it is actually
        // faster to always set avoiding removing key / values from the
        // dictionary.
        nodes[position] = newValue
      }
    }
  }


  // hacked from
  // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html
  public enum Heading {
    case up, down, left, right

    public var left: Heading {
      switch self {
        case .up:    return .left
        case .left:  return .down
        case .down:  return .right
        case .right: return .up
      }
    }

    public var right: Heading {
      switch self {
        case .up:    return .right
        case .right: return .down
        case .down:  return .left
        case .left:  return .up
      }
    }

    public var opposite: Heading {
      switch self {
        case .up:    return .down
        case .right: return .left
        case .down:  return .up
        case .left:  return .right
      }
    }
  }

  // hacked from https://developer.apple.com/documentation/swift/hashable
  public struct Point: Hashable {
    public static let origin = Point(x: 0, y: 0)

    // Compare two given points for equality.
    public static func ==(lhs: Point, rhs: Point) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public let x, y: Int

    // Access the neighbour point in the given direction.
    // NOTE: y axis goes downward.
    public subscript(_ direction: Heading) -> Point {
        switch direction {
          case .up:    return Point(x: x, y: y - 1)
          case .right: return Point(x: x + 1, y: y)
          case .left:  return Point(x: x - 1, y: y)
          case .down:  return Point(x: x, y: y + 1)
        }
    }

    // Conform to Hashable.
    public var hashValue: Int {
      return x.hashValue ^ y.hashValue &* 16777619
    }
  }
}
