// Teh memory vortex!
public class Spinlock: CustomStringConvertible {
  let step: Int          // count of step performed at each spin
  var state: [Int] = [0] // the memory
  var position: Int = 0  // the current position

  // Create a new deadly spinlock looking like a massive pixelated hurricane
  // given its number of step performed per spin.
  public init(step: Int) {
    self.step = step
  }

  // Make the lock spin a given number of times.
  public func spin(count: Int = 1) {
    for _ in 0..<count {
      position = (position + step) % state.count + 1
      state.insert(state.count, at: position)
    }
  }

  // Return the memory value at the given offset *from the current position*.
  public subscript(offset: Int) -> Int {
    return state[(position + offset) ÷ state.count]
  }

  // Display the lock state.
  public var description: String {
    let (head, current, tail) = (0, position, state.count - 1)
    return state.enumerated().map { (i, x) in
      switch i {
        case current: return "(\(x))"
        case head:    return "\(x) "
        case tail:    return " \(x)"
        default:      return " \(x) "
      }
    }.joined()
  }
}

// Modulo operators based on swift's reminder (%) operator.
infix operator ÷  : MultiplicationPrecedence
infix operator ÷= : AssignmentPrecedence

func ÷<T: BinaryInteger>(x: T, m: T) -> T {
  let r = x % m
  return (r < 0 ? r + m : r)
}

func ÷=<T: BinaryInteger>(x: inout T, m: T) {
  x %= m
  if x < 0 {
    x += m
  }
}
