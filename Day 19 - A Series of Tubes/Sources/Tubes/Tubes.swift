// The series of Tubes from the routing diagram.
public class Tubes {
  // Represents a routing diagram with lines.
  public class RoutingDiagram {
    // Line type the packet may encounter on its way.
    public enum Line: Equatable, CustomStringConvertible {
      case letter(Character)
      case vertical   // |
      case horizontal // -
      case cross      // +
      case void       // space

      // Returns true if both line are equals, false otherwise. Note that only
      // the line type (and its Character if any) is checked, not the position.
      public static func ==(lhs: Line, rhs: Line) -> Bool {
        switch (lhs, rhs) {
          case (.letter(let a), .letter(let b)): return a == b
          case (.vertical,   .vertical):   fallthrough
          case (.horizontal, .horizontal): fallthrough
          case (.cross,      .cross):      fallthrough
          case (.void,       .void):       return true
          default: return false
        }
      }

      // Parse the given Character as a Line.
      static func parse(_ c: Character) -> Line {
        switch c {
          case "|": return .vertical
          case "-": return .horizontal
          case "+": return .cross
          case " ": return .void
          default:  return .letter(c)
        }
      }

      // Returns a string containing the line letter, an empty string
      // otherwise.
      public var description: String {
        if case .letter(let c) = self {
          return "\(c)"
        } else {
          return ""
        }
      }
    }

    let diagram: [[Line]]

    // Parse a routing diagram from the given String.
    public convenience init(_ s: String) {
      self.init(s.split(separator: "\n").map(String.init))
    }

    // Parse a routing diagram from the given Strings.
    public convenience init(_ lines: [String]) {
      self.init(lines.map(Array.init))
    }

    // Parse a routing diagram a Character matrix.
    init(_ chars: [[Character]]) {
      diagram = chars.map { $0.map { c in Line.parse(c) } }
    }

    // Returns the line at the given point in this diagram, .void if the point
    // is outside bounds.
    subscript(p: Point) -> Line {
      if (0..<diagram.count).contains(p.y) {
        let xs = diagram[p.y]
        if (0..<xs.count).contains(p.x) {
          return xs[p.x]
        }
      }
      return .void
    }

    // The starting point of this diagram.
    var start: Point? {
      let y = 0
      if let x = diagram[y].index(where: { $0 == .vertical }) {
        return Point(x: x, y: y)
      } else {
        return nil
      }
    }

    // Returns the sequence of lines encountered when following the diagram
    // starting at the start position.
    public var path: [Line] {
      var path: [Line] = []
      guard var position = start else { return path }
      var direction = Direction.south
      while self[position] != .void {
        let ahead = position[direction]
        switch (self[position], self[ahead]) {
          // cases when we need to take a turn. Have to be on a cross.
          case (.cross, .horizontal) where direction.vertical:   fallthrough
          case (.cross, .vertical)   where direction.horizontal: fallthrough
          case (.cross, .void):
            let next = Direction.all(but: direction.opposite).first(where: {
              switch self[position[$0]] {
                case .cross, .letter(_): return true
                case .vertical:   return $0.vertical
                case .horizontal: return $0.horizontal
                default: return false
              }
            })
            // If we can't find a new direction to follow, let's go back.
            direction = next ?? direction.opposite
          default: // go ahead in the same direction
            path.append(self[position])
            position = ahead
        }
      }
      return path
    }
  }

  // hacked from
  // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html
  enum Direction {
    case north, south, east, west

    // Returns all the directions without the given exception (if any).
    static func all(but except: Direction?) -> Set<Direction> {
      let all: Set<Direction> = [.north, .south, .east, .west]
      return all.filter { except == nil || $0 != except! }
    }

    // The opposite direction from this one.
    var opposite: Direction {
      switch self {
        case .north: return .south
        case .south: return .north
        case .east:  return .west
        case .west:  return .east
      }
    }

    // Returns true if this direction is vertical, false otherwise.
    var vertical: Bool {
      return self == .north || self == .south
    }

    // Returns true if this direction is horizontal, false otherwise.
    var horizontal: Bool {
      return !vertical
    }
  }

  // A point in the diagram. Note that Point(x: 0, y: 0) is at the top left.
  struct Point {
    let x, y: Int

    // Access the neighbour point in the given direction.
    subscript(_ direction: Direction) -> Point {
      switch direction {
        case .east:  return Point(x: x + 1, y: y)
        case .north: return Point(x: x, y: y - 1)
        case .west:  return Point(x: x - 1, y: y)
        case .south: return Point(x: x, y: y + 1)
      }
    }
  }
}
