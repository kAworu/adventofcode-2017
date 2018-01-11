import Foundation

// Knot Hasher.
public class KnotHash {
  public static let ROUNDS = 64
  public static let STD_LENGTH_SUFFIX: [UInt8] = [17, 31, 73, 47, 23]
  public static let BLOCK_SIZE = 16

  // Returns the given String's KnotHash result.
  public static func hash(_ bytes: String) -> Result {
    let lengths = [UInt8](bytes.utf8) + STD_LENGTH_SUFFIX
    let hasher  = KnotHash()
    for _ in 0..<ROUNDS {
      hasher.update(lengths)
    }
    return hasher.result()
  }

  // hasher's internal state members
  var state: [UInt8]
  var position: Int
  var skip_size: Int

  // Syntaxic sugar to create a hasher with the default internal state.
  public convenience init() {
    self.init(0...255)
  }

  // Syntaxic sugar to create a hasher with x...y
  convenience init(_ range: CountableClosedRange<UInt8>) {
    self.init(Array(range))
  }

  // Create a hasher from an array of bytes.
  init(_ state: [UInt8]) {
    self.state     = state
    self.position  = 0
    self.skip_size = 0
  }

  // Exposed (i.e. public) access to the first two bytes of the internal state.
  // Returns nil when the requested index is out of bound.
  public subscript(index: Int) -> UInt8? {
    if [0, 1].contains(index) && index < state.count {
      return state[index]
    } else {
      return nil
    }
  }

  // Perform one round of the Knot Hash algorithm.
  public func update(_ lengths: [UInt8]) {
    // Helper function reversing part of the given array.
    func reverse(from: Int, until: Int) {
      // swap the ith and jth element in state,
      // see https://en.wikipedia.org/wiki/XOR_swap_algorithm
      func swap(_ i: Int, _ j: Int) {
        state[i] ^= state[j]
        state[j] ^= state[i]
        state[i] ^= state[j]
      }
      var (from, until) = (from, until) // "deconst" from and until
      // NOTE: the first part of the loop condition checks if `from` is not
      // wrapped and `until` is wrapped because in that case `until` is lesser
      // than `from` *but* we should continue to swap.
      while from < state.count && until >= state.count || until > from {
        swap(from % state.count, until % state.count)
        from  += 1
        until -= 1
      }
    }
    for length in lengths {
      assert(length <= state.count, "invalid length")
      reverse(from: position, until: position + Int(length) - 1)
      position = (position + Int(length) + skip_size) % state.count
      skip_size += 1
    }
  }

  // Returns the standard hexadecimal string representation of the current
  // internal state.
  func result() -> Result {
    let step  = KnotHash.BLOCK_SIZE
    let limit = state.count
    // see https://stackoverflow.com/a/38156873/7936137
    let bytes: [UInt8] = stride(from: 0, to: limit, by: step).map { start in
      let stop = min(start + step, limit)
      let byte = state[start..<stop].reduce(0) { $0 ^ $1 }
      return byte
    }
    return Result(bytes)
  }

  // Represent a finalized KnotHash result.
  public class Result: CustomStringConvertible {
    public let bytes: [UInt8]

    // Create a result givens its bytes.
    init(_ bytes: [UInt8]) {
      self.bytes = bytes
    }

    // Standard hexadecimal String representation of a KnotHash Result.
    public var description: String {
      return bytes.map { String(format: "%02x", $0) }.joined()
    }
  }
}
