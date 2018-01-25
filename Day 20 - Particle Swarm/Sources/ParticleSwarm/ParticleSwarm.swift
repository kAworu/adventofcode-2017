import Regex

// The particles simulation the GPU needs to render.
public class ParticleSwarm {
  // Represents a particle from the system.
  public struct Particle: CustomStringConvertible {
    // Parsing stuff.
    static let LINE_REGEX = Regex("p=<(.*?)>, v=<(.*?)>, a=<(.*?)>")

    public let id: Int
    let p, v, a: Vector

    // Create a new particle from a given id and description String. Returns
    // nil on parsing failure.
    public init?(id: Int, _ s: String) {
      guard let match = Particle.LINE_REGEX.firstMatch(in: s) else { return nil }
      guard let p = Vector(match.captures[0]!) else { return nil }
      guard let v = Vector(match.captures[1]!) else { return nil }
      guard let a = Vector(match.captures[2]!) else { return nil }
      self.init(id: id, p: p, v: v, a: a)

    }

    // Create a particle from its id and position (p), velocity (v) and
    // acceleration (a) vectors.
    init(id: Int, p: Vector, v: Vector, a: Vector) {
      self.id = id
      (self.p, self.v, self.a) = (p, v, a)
    }

    // Conform to CustomStringConvertible
    public var description: String {
      return "id=\(id), p=\(p), v=\(v), a=\(a)"
    }

    // Returns true if this particle is ever expanding (will never be closer to
    // the origin), false otherwise.
    func is_expanding() -> Bool {
      // Helper function returning true if all arguments are of the same sign,
      // false otherwise.
      func f(_ i: Int, _ j: Int, _ k: Int) -> Bool {
        let abs_sum = i.magnitude + j.magnitude + k.magnitude
        let sum_abs = (i + j + k).magnitude
        return abs_sum == sum_abs
      }
      // A particle cannot move closer to the origin if it its position,
      // velocity, and acceleration are all of the same sign.
      return f(p.x, v.x, a.x) && f(p.y, v.y, a.y) && f(p.z, v.z, a.z)
    }
  }

  let particles: [Particle]

  // Create a new swarm given an array of particle description string. Returns
  // nil on parsing failure.
  public init?(_ lines: [String]) {
    var particles: [Particle] = []
    for (offset, line) in lines.enumerated() {
      guard let particle = Particle(id: offset, line) else { return nil }
      particles.append(particle)
    }
    self.particles = particles
  }

  // The count of particle in this swarm.
  public var count: Int {
    return particles.count
  }

  // The closest particle from this swarm that is closer to the origin in the
  // long run.
  public func closest_to_origin_in_the_long_run() -> Particle? {
    // Build a new set of particle that is the particles of the swarm once they
    // are all expanding from the origin.
    let particles: [Particle] = self.particles.map {
      var particle = $0 // deconst
      while !particle.is_expanding() {
        // first, increase velocity by the acceleration
        let v = particle.v + particle.a
        // then, increase the position by the velocity
        let p = particle.p + particle.v
        particle = Particle(id: particle.id, p: p, v: v, a: particle.a)
      }
      return particle
    }
    let closest = particles.min(by: { i, j in
      // A particle i will be closer to zero in the long run than another
      // particle j iff its acceleration is smaller.
      if i.a.length != j.a.length {
        return i.a.length < j.a.length
      // If both have the same acceleration then check the velocity.
      } else if i.v.length != j.v.length {
        return i.v.length < j.v.length
      // If both have the same acceleration and velocity then it ultimately
      // depends on their position.
      } else {
        return i.p.length < j.p.length
      }
    })
    return closest
  }

  // Represents a three dimensional vector.
  struct Vector: Equatable, CustomStringConvertible {
    // Parsing stuff.
    static let NUMBER_REGEX = Regex("-?[0-9]+")

    // Conform to Equatable
    static func ==(lhs: Vector, rhs: Vector) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    // Returns a new vector that is the sum of the two given vectors.
    static func +(lhs: Vector, rhs: Vector) -> Vector {
      return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    let x, y, z: Int

    // Create a vector from a given description string. Returns nil if parsing
    // failed.
    init?(_ s: String) {
      let matches = Vector.NUMBER_REGEX.allMatches(in: s).map {
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

    // Returns the "length" (Manhattan distance) of this vector.
    var length: UInt {
      // Manhattan distance in a cube grid.
      return x.magnitude + y.magnitude + z.magnitude
    }
  }
}

