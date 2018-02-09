// Lehmer PRNG,
// see https://en.wikipedia.org/wiki/Lehmer_random_number_generator
public struct MINSTD: Sequence {
  public static let M31: UInt64 = 2_147_483_647 // modulus n

  // g values, should be a primitive root modulo n.
  public enum Factor: UInt64 {
    case original = 16_807 // 7⁵ as suggested in 1988
    case revised  = 48_271 // suggested in 1993
  }

  let x0, factor, n: UInt64

  // Create a new generator. x0 should be coprime to n.
  public init(first x0: Int, factor: Factor, n: UInt64 = MINSTD.M31) {
    self.x0     = UInt64(x0)
    self.factor = factor.rawValue
    self.n      = n
  }

  // Returns a new iterator over the generator values.
  public func makeIterator() -> Iterator {
    return Iterator(self)
  }

  // Iterator over a MINSTD PRNG values.
  public struct Iterator: IteratorProtocol {
    let generator: MINSTD
    var state: UInt64

    // Create an iterator given its generator.
    init(_ generator: MINSTD) {
      self.generator = generator
      self.state     = generator.x0
    }

    // Generate and return a new random number.
    // NOTE: Although an UInt64 is returned  only the last 31 bits are set when
    //       using MINSTD.M31 as modulus n.
    public mutating func next() -> UInt64? {
      state = (state * generator.factor) % generator.n
      return state
    }
  }
}
