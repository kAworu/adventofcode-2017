extension SporificaVirus {
  // Represents the nodes states in the grid.
  public class Grid {
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

    // Represents a node status.
    public enum Status: Character {
      case infected = "#"
      case clean    = "."
      case weakened = "W"
      case flagged  = "F"
    }

    // hacked from
    // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html
    public enum Heading {
      case up, down, left, right

      // The heading on the left of this one (clockwise).
      public var left: Heading {
        switch self {
          case .up:    return .left
          case .left:  return .down
          case .down:  return .right
          case .right: return .up
        }
      }

      // The heading on the right of this one (clockwise).
      public var right: Heading {
        switch self {
          case .up:    return .right
          case .right: return .down
          case .down:  return .left
          case .left:  return .up
        }
      }

      // The opposite heading of this one.
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
      public static func == (lhs: Point, rhs: Point) -> Bool {
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
    }
  }
}
