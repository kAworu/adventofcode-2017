import Regex

extension ParticleSwarm {
  // Represents a particle from the system.
  public class Particle: Hashable, CustomStringConvertible {
    // Parsing stuff.
    static let LINE_REGEX = Regex("p=<(.*?)>, v=<(.*?)>, a=<(.*?)>")

    // Compare two given particle for equality.
    public static func == (lhs: Particle, rhs: Particle) -> Bool {
      return lhs.id == rhs.id && [lhs.p, lhs.v, lhs.a] == [rhs.p, rhs.v, rhs.a]
    }

    public let id: Int
    let p, v, a: Math.Vector

    // Create a new particle from a given id and description String. Returns
    // nil on parsing failure.
    public convenience init?(id: Int, _ s: String) {
      guard let match = Particle.LINE_REGEX.firstMatch(in: s) else { return nil }
      guard let p = Math.Vector(match.captures[0]!) else { return nil }
      guard let v = Math.Vector(match.captures[1]!) else { return nil }
      guard let a = Math.Vector(match.captures[2]!) else { return nil }
      self.init(id: id, p: p, v: v, a: a)

    }

    // Create a particle from its id and position (p), velocity (v) and
    // acceleration (a) vectors.
    init(id: Int, p: Math.Vector, v: Math.Vector, a: Math.Vector) {
      self.id = id
      (self.p, self.v, self.a) = (p, v, a)
    }

    // Conform to CustomStringConvertible
    public var description: String {
      return "id=\(id), p=\(p), v=\(v), a=\(a)"
    }

    // Conform to Hashable
    public var hashValue: Int {
      return id.hashValue
    }

    // Returns true if this particle is ever expanding (will never be closer to
    // the origin), false otherwise.
    func is_expanding() -> Bool {
      // Helper function returning true if all arguments are of the same sign,
      // false otherwise.
      func s(_ i: Int, _ j: Int, _ k: Int) -> Bool {
        let abs_sum = i.magnitude + j.magnitude + k.magnitude
        let sum_abs = (i + j + k).magnitude
        return abs_sum == sum_abs
      }
      // A particle cannot move closer to the origin if it its position,
      // velocity, and acceleration are all of the same sign.
      return s(p.x, v.x, a.x) && s(p.y, v.y, a.y) && s(p.z, v.z, a.z)
    }

    // Returns the collision happening with self and the given other particle,
    // or nil if they don't collide.
    func collision(with other: Particle) -> Collision? {
      // Try to solve the quadratic equation for the x axis.
      let a = Double(self.a.x - other.a.x) / 2.0
      let b = (Double(self.v.x) + Double(self.a.x) / 2.0) -
        (Double(other.v.x) + Double(other.a.x) / 2.0)
      let c = Double(self.p.x - other.p.x)
      let solutions = Math.quad(a, b, c) // can return up to two solutions.
      // We need a positive "whole" number since we're working with discrete
      // time and positions.
      let times = solutions.filter {
        $0 > 0 && $0.truncatingRemainder(dividingBy: 1) == 0
      }.map { UInt($0) }
      // Now check at the solutions for the x axis if the position match, i.e.
      // if it is also a solution for the y and z axis. We could re-do the
      // quad() dance for y and z but checking the position at a given time is
      // more straightforward and readable.
      let collision_times = times.filter {
          self.position(at: $0) == other.position(at: $0)
      }
      // The first time match for a position is the collision time.
      if let time = collision_times.min() {
        return Collision(at: UInt(time), particles: [self, other])
      } else {
        return nil
      }
    }

    // Returns the position at the given time.
    func position(at t: UInt) -> Math.Point {
      let t = Double(t) // simplify computations.
      // Quadratic function helper.
      func f(_ p: Double, _ v: Double, _ a: Double) -> Int {
        return Int(p + t * (v + (a / 2.0)) + t * t * a / 2.0)
      }
      let x = f(Double(p.x), Double(v.x), Double(a.x))
      let y = f(Double(p.y), Double(v.y), Double(a.y))
      let z = f(Double(p.z), Double(v.z), Double(a.z))
      return Math.Point(x: x, y: y, z: z)
    }
  }
}
