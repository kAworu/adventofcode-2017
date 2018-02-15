extension ParticleSwarm {
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
      // NOTE: the position constraint is going to be ensured by the
      // constructor, but we need to check the time constraint.
      guard other.time == self.time else { return nil }
      let particles = self.particles.union(other.particles)
      return Collision(at: time, particles: particles)
    }

    // Returns a new collision that is this collisions without the given set of
    // particles, nil if the subtraction yield less than two particles.
    func without(_ to_remove: Set<Particle>) -> Collision? {
      let particles = self.particles.subtracting(to_remove)
      return Collision(at: time, particles: particles)
    }

    // This collision's position.
    public var position: Math.Point {
      return particles.first!.position(at: time)
    }
  }
}
