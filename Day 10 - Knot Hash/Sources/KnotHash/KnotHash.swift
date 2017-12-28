// Knot Hasher.
public class KnotHash {
  let list: [Int]

  // Syntaxic sugar to create a hasher with x..<y
  public convenience init(_ range: CountableRange<Int>) {
    self.init(Array(range))
  }

  // Syntaxic sugar to create a hasher with x...y
  public convenience init(_ range: CountableClosedRange<Int>) {
    self.init(Array(range))
  }

  // Create a hasher from a list of numbers.
  public init(_ list: [Int]) {
    self.list = list
  }

  // Returns the the list hash given a String description of lengths (comma
  // separated numbers).
  public func hash(lengths s: String) -> Int {
    let lengths = s.split(separator: ",").map { Int($0)! }
    return hash(lengths: lengths)
  }

  // Returns the the list hash given a list of lengths.
  public func hash(lengths: [Int]) -> Int {
    // Helper function reversing part of the given list.
    func reverse(_ list: inout [Int], from: Int, until: Int) {
      // swap the ith and jth element in list,
      // see https://en.wikipedia.org/wiki/XOR_swap_algorithm
      func swap(_ i: Int, _ j: Int) {
        list[i] ^= list[j]
        list[j] ^= list[i]
        list[i] ^= list[j]
      }
      var (from, until) = (from, until)
      while from < list.count && until >= list.count || until > from {
        swap(from % list.count, until % list.count)
        from  += 1
        until -= 1
      }
    }
    var (list, pos) = (self.list, 0)
    for (skip_size, length) in lengths.enumerated() {
      assert(length <= list.count, "invalid length")
      reverse(&list, from: pos, until: pos + length - 1)
      pos = (pos + length + skip_size) % list.count
    }
    return (list[0] * list[1])
  }
}
