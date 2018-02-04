import Regex

// The particles simulation the GPU needs to render.
public class ParticleSwarm {
  // Represents a particle from the system.
  public class Particle: Hashable, CustomStringConvertible {
    // Parsing stuff.
    static let LINE_REGEX = Regex("p=<(.*?)>, v=<(.*?)>, a=<(.*?)>")

    // Compare two given particle for equality.
    public static func ==(lhs: Particle, rhs: Particle) -> Bool {
      return lhs.id == rhs.id && [lhs.p, lhs.v, lhs.a] == [rhs.p, rhs.v, rhs.a]
    }

    public let id: Int
    let p, v, a: Vector

    // Create a new particle from a given id and description String. Returns
    // nil on parsing failure.
    public convenience init?(id: Int, _ s: String) {
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
      let solutions = quad(a, b, c) // here we may have up to two solutions.
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
    func position(at t: UInt) -> Point {
      let t = Double(t) // simplify computations.
      // Quadratic function helper.
      func f(_ p: Double, _ v: Double, _ a: Double) -> Int {
        return Int(p + t * (v + (a / 2.0)) + t * t * a / 2.0)
      }
      let x = f(Double(p.x), Double(v.x), Double(a.x))
      let y = f(Double(p.y), Double(v.y), Double(a.y))
      let z = f(Double(p.z), Double(v.z), Double(a.z))
      return Point(x: x, y: y, z: z)
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
    // If we look at a particle's vectors (acceleration, velocity, and
    // position) they will all have in the long run the same sign wrt each axis
    // (x, y, and z). Since the acceleration doesn't change, it will be the
    // acceleration's values sign. We call the time when a particle has all its
    // vector of the same sign on each axis the "expanding" state because at
    // that point it only goes further and further from the origin.

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
      if i.a.magnitude != j.a.magnitude {
        return i.a.magnitude < j.a.magnitude
      // If both have the same acceleration then check the velocity.
      } else if i.v.magnitude != j.v.magnitude {
        return i.v.magnitude < j.v.magnitude
      // If both have the same acceleration and velocity then it ultimately
      // depends on their position.
      } else {
        return i.p.magnitude < j.p.magnitude
      }
    })
    return closest
  }

  // Returns all the collisions happening in the system.
  public func collisions() -> [Collision] {
    var collisions: [Collision] = []
    for i in 0..<particles.count {
      for j in (i + 1)..<particles.count {
        let (pi, pj) = (particles[i], particles[j])
        if let collision = pi.collision(with: pj) {
          // So pi and pj collide at some point. We need to find other
          // collisions happening with either pi or pj.
          let cut = collisions.partition(by: {
            $0.shared_particles(with: collision).isEmpty
          })
          let (with, without) = (collisions[..<cut], collisions[cut...])
          if with.isEmpty {
            // This is the easy case, there are no other collision sharing a
            // particle with the current one. Simply add the current collision
            // to the list.
            collisions.append(collision)
          } else if with.contains(where: { $0.time < collision.time }) {
            // There is another collision with either pi or pj happening before
            // the current collision. Thus, we skip it.
            continue
          } else {
            // There is at least another collision with one of our particle
            // happening at the same time or after us. Note that collisions
            // happening at the same time also happen at the same place since
            // they share a particle with the current collision.
            let same_time = with.filter { $0.time == collision.time }
            let after     = with.filter { $0.time >  collision.time }
            // Collisions happening at the same time and place should be merged
            // into one.
            let merged = same_time.reduce(collision) { $0.merge(with: $1)! }
            // We need to remove pi and pj from collisions happening after the
            // current one since they are destroyed at the current collision
            // time.
            let maybe_after = after.map { $0.without(collision.particles) }
            // Finally, our collisions are those without either pi or pj
            // (untouched), the current one merged with those happening at the
            // same time and position, and those happening after that are still
            // happening.
            collisions = without + [merged] + maybe_after.flatMap { $0 }
          }
        }
      }
    }
    return collisions
  }

  // Represents a collision at a given time and position happening between
  // multiple particles.
  public struct Collision {
    public let time: UInt
    public let particles: Set<Particle>

    // Create a collision at the given time destroying the provided particles.
    // NOTE: The particles should all be at the same position at the given time
    //       and there should be more than one particle for a collision to
    //       occur, otherwise nil is returned.
    init?(at time: UInt, particles: Set<Particle>) {
      if particles.count < 2 {
        return nil
      }
      let position = particles.first!.position(at: time)
      if particles.contains(where: { $0.position(at: time) != position }) {
        return nil
      }
      self.time = time
      self.particles = particles
    }

    // Returns the set of particles that are both in this collision and the
    // given other collision.
    func shared_particles(with other: Collision) -> Set<Particle> {
      return particles.intersection(other.particles)
    }

    // Returns a new collisions with all the particles in this one and the
    // given other one. The two collision must happen at the same time and
    // position, otherwise nil is returned.
    func merge(with other: Collision) -> Collision? {
      guard other.time == self.time         else { return nil }
      guard other.position == self.position else { return nil }
      let particles = self.particles.union(other.particles)
      return Collision(at: time, particles: particles)!
    }

    // Returns a new collision that is this collisions without the given set of
    // particles, nil if the subtraction yield less than two particles.
    func without(_ to_remove: Set<Particle>) -> Collision? {
      let particles = self.particles.subtracting(to_remove)
      return Collision(at: time, particles: particles)
    }

    // This collision's position.
    public var position: Point {
      return particles.first!.position(at: time)
    }
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
    public static func ==(lhs: Point, rhs: Point) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    let x, y, z: Int

    // Conform to Hashable.
    public var hashValue: Int {
      return x.hashValue ^ y.hashValue ^ z.hashValue &* 16777619
    }
  }
}

// Helper returning the root(s) for the quadratic equation of the form
// ax² + bx + c.
func quad(_ a: Double, _ b: Double, _ c: Double) -> [Double] {
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
