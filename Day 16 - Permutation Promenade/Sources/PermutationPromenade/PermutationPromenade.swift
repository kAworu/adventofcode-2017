import Regex

// Dancing operators.
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Sets
infix operator ♪ : AdditionPrecedence // dance one move
infix operator ♫ : AdditionPrecedence // dance a full tune
infix operator ♯ : MultiplicationPrecedence // dance a tune many times

// Our group of dancing programs.
public class PermutationPromenade: CustomStringConvertible, Hashable {
  typealias Program = Character

  // Compare two given program groups for equality.
  public static func ==(lhs: PermutationPromenade, rhs: PermutationPromenade) -> Bool {
    return "\(lhs)" == "\(rhs)"
  }

  // Make the group dance a song (moves separated by comma).
  @discardableResult
  public static func ♫ (dancers: PermutationPromenade, song: String) -> PermutationPromenade {
    return dancers ♫ Tune(song)
  }

  // Make the group dance a single move.
  static func ♪ (dancers: PermutationPromenade, move: Move) -> PermutationPromenade {
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
  public var hashValue: Int {
    return description.hashValue
  }

  // Represent a serie of move to be performed a number of times.
  public struct Tune {
    // Returns a new tune that is the given one repeated n times.
    public static func ♯ (to_repeat: Tune, n: Int) -> Tune {
      return Tune(moves: to_repeat.moves, times: n * to_repeat.times)
    }

    // Make the given group dance to the provided tune.
    @discardableResult
    public static func ♫ (dancers: PermutationPromenade, tune: Tune) -> PermutationPromenade {
      var dancers = dancers
      var memoized: [PermutationPromenade: Int] = [:]
      for time in 0..<tune.times {
        dancers = tune.moves.reduce(dancers, ♪)
        // NOTE: shortcut the dance if we can. If we've already seen this
        // position from a previous iteration we've detected a loop. We can
        // then compute and return the final position.
        if let seen = memoized[dancers] {
          let size = time - seen // the loop size
          let left = tune.times - time - 1 // # of iteration left to do
          let reminder = left ÷ size // # of iteration left to do after the loop
          // Returns the group that has the reminder index in the loop.
          return memoized.first(where: { $0.value == reminder })!.key
        }
        memoized[dancers] = time
      }
      // here we've made the dancer do the moves the total requested number of
      // times.
      return dancers
    }

    let moves: [Move] // the moves in this tune
    let times: Int    // the number of time moves are repeated

    // Create a tune from a string description of moves.
    public init(_ song: String) {
      let moves = song.split(separator: ",").map { Move.parse(String($0))! }
      self.init(moves: moves)
    }

    // Create a tune given its serie of moves and the repetition count.
    init(moves: [Move], times: Int = 1) {
      self.moves = moves
      self.times = times
    }
  }

  // Represent a dance move.
  enum Move {
    static let RE = ( // parsing stuff
      spin:     Regex("s([0-9]+)"),
      exchange: Regex("x([0-9]+)/([0-9]+)"),
      partner:  Regex("p([a-z])/([a-z])"))

    case spin(Int)
    case exchange(Int, Int)
    case partner(Program, Program)

    // Parse a move string.
    static func parse(_ s: String) -> Move? {
      if let match = Move.RE.spin.firstMatch(in: s) {
        let size = Int(match.captures[0]!)!
        return .spin(size)
      }
      if let match = Move.RE.exchange.firstMatch(in: s) {
        let p = Int(match.captures[0]!)!
        let q = Int(match.captures[1]!)!
        return .exchange(p, q)
      }
      if let match = Move.RE.partner.firstMatch(in: s) {
        let a = Program(match.captures[0]!)
        let b = Program(match.captures[1]!)
        return .partner(a, b)
      }
      return nil
    }
  }
}

// Syntaxic sugar for (Tune ♯ Int)
public func ♯ (song: String, n: Int) -> PermutationPromenade.Tune {
  return PermutationPromenade.Tune(song) ♯ n
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
