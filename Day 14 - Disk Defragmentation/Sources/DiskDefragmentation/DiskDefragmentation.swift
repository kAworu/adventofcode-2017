// The disk's grid.
public class DiskDefragmentation {
  public static let HEIGHT = 128 // default grid's height

  // This grid's rows.
  let rows: [Row]

  // Create a disk grid given its hash key input and its height.
  public init(key: String, height: Int = DiskDefragmentation.HEIGHT) {
    let inputs = (0..<height).map { "\(key)-\($0)" }
    self.rows  = inputs.map { Row(input: $0) }
  }

  // Returns the grid's height.
  var height: Int {
    return rows.count
  }

  // Returns the count of used (i.e. non-free) squares.
  public var used_square_count: Int {
    return rows.reduce(0) { $0 + $1.used_square_count }
  }

  // Returns the count of regions in this grid.
  public var region_count: Int {
    var count = 0
    var grouped: Set<Point> = [] // Set of square point already accounted for
    for y in 0..<height {
      for x in 0..<rows[y].width {
        let point = Point(x: x, y: y)
        if is_used(at: point)! && !grouped.contains(point) {
          count += 1
          grouped.formUnion(region(of: point))
        }
      }
    }
    return count
  }

  // Returns the Set of points in the same region of the given member
  // (including itself). Returns an empty Set when the starting point is either
  // free or invalid (i.e. outside bounds).
  func region(of member: Point) -> Set<Point> {
    var region: Set<Point> = []
    // Helper to walk through each point of the region, building the region Set.
    func visit(_ point: Point) {
      guard let square_is_used = is_used(at: point) else { return }
      if square_is_used && !region.contains(point) {
        region.insert(point)
        for neighbour in point.neighbours {
          visit(neighbour)
        }
      }
    }
    visit(member)
    return region
  }

  // Returns true if the square at the given point is used, false otherwise.
  func is_used(at point: Point) -> Bool? {
    guard (0..<height).contains(point.y) else { return nil }
    return rows[point.y].is_used(point.x)
  }

  // Represents one row of the grid.
  class Row {
    let hash: KnotHash.Result

    // Create a row given an input String. The row's square will be set from
    // the input's KnotHash result.
    init(input: String) {
      hash = KnotHash.hash(input)
    }

    // Returns this row's width.
    var width: Int {
      return 8 * hash.bytes.count // 8 bits per byte.
    }

    // Returns the count of used square in this row.
    var used_square_count: Int {
      return hash.popcnt
    }

    // Returns true if the square at the given index is used, false otherwise.
    func is_used(_ at: Int) -> Bool? {
      guard (0..<width).contains(at) else { return nil }
      let (index, offset) = (at / 8, at % 8)
      return hash.bytes[index] & (0b10000000 >> offset) > 0
    }
  }

  // stolen from
  // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html
  enum Direction {
    case north, south, east, west
  }

  // hacked from https://developer.apple.com/documentation/swift/hashable
  struct Point {
    let x: Int
    let y: Int

    // give access to neighbour points
    subscript(_ direction: Direction) -> Point {
        switch direction {
          case .east:  return Point(x: x + 1, y: y)
          case .north: return Point(x: x, y: y + 1)
          case .west:  return Point(x: x - 1, y: y)
          case .south: return Point(x: x, y: y - 1)
        }
        // NOTREACHED
    }

    // Returns the neighbours points of this one.
    var neighbours: Set<Point> {
      return [
        self[.east], self[.north], self[.west], self[.south]
      ]
    }
  }
}

extension DiskDefragmentation.Point: Hashable {
  var hashValue: Int {
    return x.hashValue ^ y.hashValue &* 16777619
  }

  static func ==(lhs: DiskDefragmentation.Point, rhs: DiskDefragmentation.Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
}

import KnotHash
extension KnotHash.Result {
  // Hamming weight over the KnotHash.Result bytes.
  var popcnt: Int {
    return bytes.reduce(0) { $0 + $1.nonzeroBitCount }
  }
}
