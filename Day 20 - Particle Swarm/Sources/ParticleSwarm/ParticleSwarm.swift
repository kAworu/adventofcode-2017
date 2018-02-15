// The particles simulation the GPU needs to render.
public class ParticleSwarm {
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
}
