// Dancing operators.
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Sets
infix operator ♪ : AdditionPrecedence // dance one move
infix operator ♫ : AdditionPrecedence // dance a full tune
infix operator ♯ : MultiplicationPrecedence // dance a tune many times

// Our group of dancing programs.
public class PermutationPromenade: CustomStringConvertible, Hashable {
  typealias Program = Character

  // Compare two given program groups for equality.
  public static func == (lhs: PermutationPromenade, rhs: PermutationPromenade) -> Bool {
    return "\(lhs)" == "\(rhs)"
  }

  // Make the group dance a song (moves separated by comma).
  @discardableResult
  public static func ♫ (dancers: PermutationPromenade, song: String) -> PermutationPromenade {
    return dancers ♫ Tune(song)
  }

  // Make the group dance a single move.
  static func ♪ (dancers: PermutationPromenade, move: Tune.Move) -> PermutationPromenade {
    switch move {
      case .spin(let size):
        let cut = (dancers.count - size) ÷ dancers.count
        var (head, tail) = (dancers.programs[..<cut], dancers.programs[cut...])
        tail.append(contentsOf: head)
        return PermutationPromenade(Array(tail))
      case .exchange(let i, let j):
        var programs = dancers.programs
        programs.swapAt(i, j)
        return PermutationPromenade(programs)
      case .partner(let a, let b):
        let i = dancers.programs.index(of: a)!
        let j = dancers.programs.index(of: b)!
        var programs = dancers.programs
        programs.swapAt(i, j)
        return PermutationPromenade(programs)
    }
  }

  // The programs forming this group.
  let programs: [Program]

  // Create a new group given the program count.
  public convenience init(count n: Int) {
    var programs: [Program] = []
    let a = Int("a".utf8.first!) // 97
    for i in 0..<n {
      let program = Program(UnicodeScalar(a + i)!)
      programs.append(program)
    }
    self.init(programs)
  }

  // Create a new group given its programs.
  init(_ programs: [Program]) {
    self.programs = programs
  }

  // Program count in the group.
  var count: Int {
    return programs.count
  }

  // Display the programs in order.
  public var description: String {
    return String(programs)
  }

  // Conform to Hashable.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(description)
  }
}

// Modulo operators based on swift's reminder (%) operator.
infix operator ÷  : MultiplicationPrecedence
infix operator ÷= : AssignmentPrecedence

func ÷<T: BinaryInteger>(x: T, m: T) -> T {
  return (x + m) % m
}

func ÷=<T: BinaryInteger>(x: inout T, m: T) {
  x %= m
  if x < 0 {
    x += m
  }
}
