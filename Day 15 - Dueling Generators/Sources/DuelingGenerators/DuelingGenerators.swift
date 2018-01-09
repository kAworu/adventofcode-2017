import MINSTD

// The encountered pair of generators.
public class DuelingGenerators {
  let first: (A: Int, B: Int)

  // Create a new pair of generator given their initial value.
  public init(A: Int, B: Int) {
    self.first = (A: A, B: B)
  }

  // Returns the judge's final count after a given sample pairs are considered.
  public func final_count(sample: Int = 40_000_000) -> Int {
    var match = 0 // judge's match count.
    let A = MINSTD(first: first.A, factor: MINSTD.Factor.original)
    let B = MINSTD(first: first.B, factor: MINSTD.Factor.revised)
    for _ in 0..<sample {
      match += ((A.next() ^ B.next()) & 0xffff) == 0 ? 1 : 0
    }
    return match
  }
}
