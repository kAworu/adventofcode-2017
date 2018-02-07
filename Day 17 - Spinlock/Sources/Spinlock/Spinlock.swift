// Teh memory vortex!
public class Spinlock: CustomDebugStringConvertible {
  let step: Int          // count of step performed at each spin.
  var state: [Int] = [0] // the memory.
  var position: Int = 0  // the current position.

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

  // Return the memory value at the given offset relative to the provided
  // position.
  public func next_to(_ value: Int) -> Int? {
    guard let position = state.index(of: value) else { return nil }
    return state[(position + 1) % state.count]
  }

  // Display the lock state.
  public var debugDescription: String {
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


// A fake kind of Spinlock, not nearly as deadly and looking more like an
// internet friday cat meme than a hurricane. This kind of spinlock don't suck
// up memory like a vortex but rather only keep track of the first two values
// (i.e. 0 and the next one).
public class FakeSpinlock {
  let step: Int         // count of step performed at each spin.
  var spin: Int = 0     // the spin count.
  var position: Int = 0 // the current position.
  public private(set) var next_to_zero: Int? = nil // the value next to zero.

  // Create a fake spinlock given its number of step performed per spin.
  public init(step: Int) {
    self.step = step
  }

  // Make the lock spin a given number of times.
  public func spin(count: Int = 1) {
    for i in 1...count {
      position = (position + step) % (spin + i) + 1
      if position == 1 {
        next_to_zero = spin + i
      }
    }
    spin += count
  }
}
