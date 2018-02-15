import Regex

extension ParticleSwarm {
  // All the mathematical stuff.
  public class Math {
    // Helper returning the root(s) for the quadratic equation of the form
    // ax² + bx + c.
    static func quad(_ a: Double, _ b: Double, _ c: Double) -> [Double] {
      if a != 0 {
        let Δ = b * b - 4 * a * c
        if Δ > 0 {
          // If the discriminant is positive, then there are two distinct
          // roots.
          let sq = Δ.squareRoot()
          return [(-b - sq) / (2 * a), (-b + sq) / (2 * a)]
        } else if Δ == 0 {
          // If the discriminant is zero, then there is exactly one real
          // root.
          return [-b / (2 * a)]
        }
      } else if b != 0 {
        // linear equation, exactly one root.
        return [-c / b]
      } else if c == 0 {
        // NOTE: here we have a == b == c == 0 so any value is a solution.
        // For our purpose the collision time is simply zero.
        return [0]
      }
      // a == b == 0 and c != 0 means no solutions.
      return []
    }

    // Represents a three dimensional vector.
    struct Vector: Equatable, CustomStringConvertible {
      private static let RE = Regex("-?[0-9]+")

      // Conform to Equatable
      static func == (lhs: Vector, rhs: Vector) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
      }

      // Returns a new vector that is the sum of the two given vectors.
      static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
      }

      let x, y, z: Int

      // Create a vector from a given description string. Returns nil if parsing
      // failed.
      init?(_ s: String) {
        let matches = Vector.RE.allMatches(in: s).map {
          $0.matchedString
        }
        if matches.count != 3 {
          return nil
        } else {
          let (x, y, z) = (Int(matches[0])!, Int(matches[1])!, Int(matches[2])!)
          self.init(x: x, y: y, z: z)
        }
      }

      // Create a vector given its terminal point x, y, and z values.
      init(x: Int, y: Int, z: Int) {
        (self.x, self.y, self.z) = (x, y, z)
      }

      // Conform to CustomStringConvertible
      public var description: String {
        return "<\(x),\(y),\(z)>"
      }

      // Returns the Manhattan distance of this vector.
      var magnitude: UInt {
        // Manhattan distance in a cube grid.
        return x.magnitude + y.magnitude + z.magnitude
      }
    }

    // inspired by https://developer.apple.com/documentation/swift/hashable
    public struct Point: Hashable {
      public static let origin = Point(x: 0, y: 0, z: 0)

      // Conform to Equatable
      public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
      }

      public let x, y, z: Int

      public // Conform to Hashable.
      var hashValue: Int {
        return x.hashValue ^ y.hashValue ^ z.hashValue &* 16777619
      }
    }
  }
}
