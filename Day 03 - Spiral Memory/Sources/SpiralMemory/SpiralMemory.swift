// An experimental new kind of memory.
public struct SpiralMemory {
  let target: Int

  // Create a new Spiral Memory searcher for the given target.
  public init(_ target: Int) {
    self.target = target
  }

  // Returns the steps count between the access port and our target.
  public var snake_distance: Int {
    // Each spirale "circle" ends with the square of an odd number. We'll call
    // this number the circle's "level", and it follow that the circle level n
    // contains the numbers between (n - 2) ** 2 + 1 and n ** 2.

    // first let's find out on which "circle level" is the target. The last
    // number of each circle is a square:
    // - the first is 9 ->   "level 3" (3 * 3 =  9),
    // - the second is 25 -> "level 5" (5 * 5 = 25),
    // - the n is level (n * 2) ** 2.
    let sqrt = Double(target).squareRoot()
    let n = Int(sqrt.rounded(.up))
    let level = n + (n % 2 == 0 ? 1 : 0)
    // We found the level, i.e. `target' is between the previous level's bottom
    // right square number ((level - 2) ** 2 + 1) and this level's bottom right
    // square (level ** 2).

    // at that point we know that we need at least (level / 2) steps to move to
    // the right circle level. we'll end up in the middle of one of the side of
    // the circle. now we may need to "drift" from the "middle side number".
    var (min, max) = (level * level - level + 1, level * level)
    // min and max are the bottom left respectively bottom right numbers of our
    // circle level. let's switch side clockwise until we find the border where
    // `target' is.
    while target < min {
      (min, max) = (min - level + 1, min)
    }
    let mid = min + (max - min) / 2 // NOTE: (max - min) is even.
    // the drift is the absolute diff between the number at the center of the
    // side and our `target'.
    let drift = Int((target - mid).magnitude)

    // move to the side directly and then drift.
    return level / 2 + drift
  }

  // Returns the first value written larger than our target by the programs
  // when stress testing the system.
  public var stress_test_gt: Int {
    var p         = GridPoint(x: 0, y: 0) // our current position
    var spiral    = [p: 1]
    var direction = CompassPoint.east
    while (spiral[p]!) <= target {
      p = p[direction] // update our position
      let (e,  n,  w,  s)  = (p[.east], p[.north], p[.west], p[.south])
      let (ne, nw, se, sw) = (n[.east], n[.west],  s[.east], s[.west])
      // compute the spiral sum at position `p', unfortunately a single
      // addition of all the values is too complex for the swift compiler for
      // now so ugly code follows.
      var sum = 0
      sum += (spiral[e]  ?? 0)
      sum += (spiral[n]  ?? 0)
      sum += (spiral[w]  ?? 0)
      sum += (spiral[s]  ?? 0)
      sum += (spiral[ne] ?? 0)
      sum += (spiral[nw] ?? 0)
      sum += (spiral[se] ?? 0)
      sum += (spiral[sw] ?? 0)
      spiral[p] = sum
      // decide the next direction
      switch (spiral[e], spiral[n], spiral[w], spiral[s]) {
        case (nil, _, nil, nil):
          direction = .east
        case (nil, nil, _, nil):
          direction = .north
        case (nil, nil, nil, _):
          direction = .west
        case (_, nil, nil, nil):
          direction = .south
        default: // do nada, keep the same direction
          break
      }
    }
    return spiral[p]!
  }
}

// stolen from
// https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html
enum CompassPoint {
  case north, south, east, west
}

// hacked from https://developer.apple.com/documentation/swift/hashable
struct GridPoint {
  let x: Int
  let y: Int

  // give access to neighbour points
  subscript(_ direction: CompassPoint) -> GridPoint {
      switch direction {
        case .east:  return GridPoint(x: x + 1, y: y)
        case .north: return GridPoint(x: x, y: y + 1)
        case .west:  return GridPoint(x: x - 1, y: y)
        case .south: return GridPoint(x: x, y: y - 1)
      }
      // NOTREACHED
  }
}

extension GridPoint: Hashable {
  var hashValue: Int {
    return x.hashValue ^ y.hashValue &* 16777619
  }

  static func ==(lhs: GridPoint, rhs: GridPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
}
