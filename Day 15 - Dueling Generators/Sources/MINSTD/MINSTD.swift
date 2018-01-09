// Lehmer PRNG,
// see https://en.wikipedia.org/wiki/Lehmer_random_number_generator
public class MINSTD {
  static let M31: UInt64 = 2_147_483_647 // modulus n

  // g values, should be a primitive root modulo n.
  public enum Factor: UInt64 {
    case original = 16_807 // 7⁵ as suggested in 1988
    case revised  = 48_271 // suggested in 1993
  }

  var state: UInt64
  let factor: UInt64

  public init(first: Int, factor: Factor) {
    self.state  = UInt64(first)
    self.factor = factor.rawValue
  }

  public func next() -> UInt64 {
    state = (state * factor) % MINSTD.M31
    return state
  }
}
