// Hex point move operator (hexagon),
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Geometric_Shapes
infix operator ⬡ : AdditionPrecedence
// Distance between two Hex points operator (horizontal ellipsis),
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Mathematical_typography
infix operator ⋯ : AdditionPrecedence

// All written by reading this super awesome resource about Hexagonal Grids:
// https://www.redblobgames.com/grids/hexagons/
public class HexGrid {
  // Returns the path in the Hex Grid after traveling the given list of
  // direction.
  public static func walk(_ path: String) -> Path {
    let directions = path.split(separator: ",").map {
      Direction(rawValue: String($0))!
    }
    return Path(directions)
  }

  // Represent a path, i.e. a succession of adjacent points in the Hex Grid.
  public struct Path {
    let positions: [Point]

    // Create a new path given directions and a starting point.
    init(_ directions: [Direction], from origin: Point = .zero) {
      var positions = [origin]
      for direction in directions {
        let current = positions.last!
        positions.append(current ⬡ direction)
      }
      self.positions = positions
    }

    // This path first point.
    var starting_point: Point {
      return positions.first!
    }

    // This path last point.
    var landing_point: Point {
      return positions.last!
    }

    // The distance between the starting and landing points.
    public var final_distance: UInt {
      return starting_point ⋯  landing_point
    }

    // The furthest distance from the starting point in this path.
    public var furthest_distance: UInt {
      return positions.map { starting_point ⋯  $0 }.max()!
    }
  }

  // inspired by https://developer.apple.com/documentation/swift/hashable
  public struct Point {
    public static let zero = Point(x: 0, y: 0, z: 0)

    let x, y, z: Int

    // Returns the neighbour of this point at the given direction.
    static func ⬡ (from: Point, direction: Direction) -> Point {
      switch direction {
        case .n:  return Point(x: from.x,     y: from.y + 1, z: from.z - 1)
        case .ne: return Point(x: from.x + 1, y: from.y,     z: from.z - 1)
        case .se: return Point(x: from.x + 1, y: from.y - 1, z: from.z    )
        case .s:  return Point(x: from.x    , y: from.y - 1, z: from.z + 1)
        case .sw: return Point(x: from.x - 1, y: from.y,     z: from.z + 1)
        case .nw: return Point(x: from.x - 1, y: from.y + 1, z: from.z    )
      }
    }

    // Returns the distance between two given points.
    // see https://www.redblobgames.com/grids/hexagons/#distances-cube
    static func ⋯ (lhs: Point, rhs: Point) -> UInt {
      // Manhattan distance in a cube grid ...
      let d = (
        (lhs.x - rhs.x).magnitude +
        (lhs.y - rhs.y).magnitude +
        (lhs.z - rhs.z).magnitude)
      // ... the distance on a hex grid is half that:
      return d / 2
    }
  }

  // Represent a Hex Grid direction.
  public enum Direction: String {
    case n, ne, se, s, sw, nw
  }
}
