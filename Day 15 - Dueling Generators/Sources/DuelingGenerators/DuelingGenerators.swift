import MINSTD

// The encountered pair of generators.
public class DuelingGenerators {
  let A, B: MINSTD

  // Create a new pair of generator given their initial value.
  public init(A: Int, B: Int) {
    self.A = MINSTD(first: A, factor: .original)
    self.B = MINSTD(first: B, factor: .revised)
  }

  // Returns the judge's final count after a given sample pairs are considered.
  public func final_count(sample: Int = 40_000_000) -> Int {
    return count(n: sample, a: self.A.makeIterator(), b: self.B.makeIterator())
  }

  // Returns the judge's final count using the new generator logic.
  public func picky_final_count(sample: Int = 5_000_000) -> Int {
    let a = FilteredIterator(self.A.makeIterator()) { $0 & 0b011 == 0 }
    let b = FilteredIterator(self.B.makeIterator()) { $0 & 0b111 == 0 }
    return count(n: sample, a: a, b: b)
  }

  // Returns the count of matching generated values from the two iterators
  // where their lowest 16 bits match (over the given number of try).
  func count<T: IteratorProtocol>(n: Int, a: T, b: T) -> Int where T.Element == UInt64 {
    var match = 0 // judge's match count.
    var (a, b) = (a, b) // deconst
    for _ in 0..<n {
      match += ((a.next()! ^ b.next()!) & 0xffff) == 0 ? 1 : 0
    }
    return match
  }

  // Represents an iterator filter.
  struct FilteredIterator<T: IteratorProtocol>: IteratorProtocol {
    var iterator: T
    let accept: (T.Element) -> Bool

    // Create a filtered iterator generating values from the given iterator
    // that are accepted by the provided function.
    init(_ iterator: T, accept: @escaping (T.Element) -> Bool) {
      self.iterator = iterator
      self.accept = accept
    }

    // Advance this iterator and returns the next value (if any).
    mutating func next() -> T.Element? {
      while true {
        guard let value = self.iterator.next() else { return nil }
        if (accept(value)) {
          return value
        }
      }
    }
  }
}
