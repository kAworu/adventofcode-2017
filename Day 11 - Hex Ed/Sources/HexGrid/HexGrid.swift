// All written by reading this super awesome resource about Hexagonal Grids:
// https://www.redblobgames.com/grids/hexagons/
public class HexGrid {

  // Returns the position after traveling the given path starting from the
  // provided initial position.
  public static func walk(path: String, from: GridPoint = .zero) -> GridPoint {
    let directions = path.split(separator: ",").map {
      Direction(rawValue: String($0))!
    }
    var position = from
    for direction in directions {
      position = position[direction]
    }
    return position
  }
}

// Represent a Hex Grid direction.
enum Direction: String {
  case n, ne, se, s, sw, nw
}

// inspired by https://developer.apple.com/documentation/swift/hashable
public struct GridPoint {
  public static let zero = GridPoint(x: 0, y: 0, z: 0)

  let x: Int
  let y: Int
  let z: Int

  subscript(_ direction: Direction) -> GridPoint {
    switch direction {
      case .n:  return GridPoint(x: x,     y: y + 1, z: z - 1)
      case .ne: return GridPoint(x: x + 1, y: y,     z: z - 1)
      case .se: return GridPoint(x: x + 1, y: y - 1, z: z    )
      case .s:  return GridPoint(x: x    , y: y - 1, z: z + 1)
      case .sw: return GridPoint(x: x - 1, y: y,     z: z + 1)
      case .nw: return GridPoint(x: x - 1, y: y + 1, z: z    )
    }
  }

  // see https://www.redblobgames.com/grids/hexagons/#distances-cube
  public func distance(from other: GridPoint) -> UInt {
    // Manhattan distance in a cube grid ...
    let d = (
      (x - other.x).magnitude +
      (y - other.y).magnitude +
      (z - other.z).magnitude)
    // ... the distance on a hex grid is half that:
    return d / 2
  }
}
