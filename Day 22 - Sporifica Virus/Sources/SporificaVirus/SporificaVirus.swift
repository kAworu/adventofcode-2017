// The local grid computing cluster.
public class SporificaVirus {
  // Function type used as status change callback by the infection burst
  // process.
  public typealias Callback = (Point) -> ()

  var grid: [Point: Status]
  var virus: Virus
  var listeners: [Status: Callback] = [:]

  // Create a computing cluster given a string description of the grid. Returns
  // nil if parsing failed.
  public convenience init?(grid s: String) {
    self.init(grid: s.split(separator: "\n").map(String.init))
  }

  // Create a computing cluster given a string description of the grid. Returns
  // nil if parsing failed.
  public init?(grid xs: [String]) {
    guard xs.count > 0 else { return nil }
    let half = xs.first!.count / 2
    // ensure that all rows are of the same size.
    guard !xs.contains(where: { $0.count != 1 + half * 2 }) else { return nil }
    var grid: [Point: Status] = [:]
    for (y, row) in xs.enumerated() {
      for (x, c) in row.enumerated() {
        guard let status = Status(rawValue: c) else { return nil }
        // NOTE: we want the center to be .origin
        let position = Point(x: x - half, y: y - half)
        grid[position] = status
      }
    }
    self.grid = grid
    self.virus = Virus(heading: .up, position: .origin)
  }

  // Register the given callback function to be called when the provided status
  // change arise. Returns the callback previously setup for the event if any.
  @discardableResult
  public func on(_ event: Status, callback: @escaping Callback) -> Callback? {
      let old = listeners[event]
      listeners[event] = callback
      return old
  }

  // Make the virus burst a given number of time.
  public func burst(times: Int = 1) {
    for _ in 0..<times {
      let current = virus.position
      switch self[current] {
        case .infected:
          virus.turn_right()
          self[current] = .clean
        default:
          virus.turn_left()
          self[current] = .infected
      }
      let status = self[current]
      if let callback = listeners[status] {
        callback(current)
      }
      virus.advance()
    }
  }

  // Returns a description of the grid with the virus frop the top-left (tl)
  // position to the bottom-right (br) position included.
  public func draw(_ tl: (x: Int, y: Int), _ br: (x: Int, y: Int)) -> String {
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
        description.append(self[position].rawValue)
      }
      if y != br.y { // don't finish with a newline.
        description.append("\n")
      }
    }
    return description
  }

  // Returns the status of the node at the given position.
  subscript(_ position: Point) -> Status {
    get {
      return grid[position] ?? .clean
    }
    set(newValue) {
      grid[position] = newValue
    }
  }

  // Teh Sporifica Virus.
  class Virus {
    var heading: Direction
    var position: Point

    // Create a virus.
    init(heading: Direction, position: Point) {
      self.heading = heading
      self.position = position
    }

    // Make this virus turn right. Returns the new direction.
    @discardableResult func turn_right() -> Direction {
      switch heading {
        case .up:    heading = .right
        case .right: heading = .down
        case .down:  heading = .left
        case .left:  heading = .up
      }
      return heading
    }

    // Make this virus turn left. Returns the new direction.
    @discardableResult func turn_left() -> Direction {
      switch heading {
        case .up:    heading = .left
        case .left:  heading = .down
        case .down:  heading = .right
        case .right: heading = .up
      }
      return heading
    }

    // Make this virus move forward. Returns the new position.
    @discardableResult func advance() -> Point {
      position = position[heading]
      return position
    }
  }

  // Represents a node status.
  public enum Status: Character {
    case infected = "#"
    case clean    = "."
  }

  // hacked from
  // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html
  public enum Direction {
    case up, down, left, right
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
    public subscript(_ direction: Direction) -> Point {
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
