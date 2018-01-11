import Regex

// Dancing operators.
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Sets
infix operator ♪ : AdditionPrecedence // dance one move
infix operator ♫ : AdditionPrecedence // dance a full tune
infix operator ♯ : MultiplicationPrecedence // dance a tune many times

// Our group of dancing programs.
public class PermutationPromenade: CustomStringConvertible {
  typealias Program = Character

  // Make the group dance a song (moves separated by comma).
  @discardableResult
  public static func ♫ (dancers: PermutationPromenade, song: String) -> PermutationPromenade {
    return dancers ♫ Tune(song)
  }

  // Make the group dance a single move.
  static func ♪ (dancers: PermutationPromenade, move: Move) -> PermutationPromenade {
    switch move {
      case .spin(let size):
        // NOTE: a Spin moves programs *from the end to the front*, hence the
        // substraction (offset moves "backward").
        let offset = (dancers.offset - size) ÷ dancers.count
        return PermutationPromenade(programs: dancers.programs, offset: offset)
      case .exchange(let p, let q):
        let (i, j) = (dancers.index(p), dancers.index(q))
        return PermutationPromenade(programs: dancers.swaped(i, j), offset: dancers.offset)
      case .partner(let a, let b):
        let (i, j) = (dancers.index(a), dancers.index(b))
        return PermutationPromenade(programs: dancers.swaped(i, j), offset: dancers.offset)
    }
  }

  let offset: Int // used to translate Position from/to index
  let programs: [Program]

  // Create a new group given the program count.
  public convenience init(count n: Int) {
    var programs: [Program] = []
    let a = Int("a".utf8.first!) // 97
    for i in 0..<n {
      let program = Program(UnicodeScalar(a + i)!)
      programs.append(program)
    }
    self.init(programs: programs)
  }

  // Create a new group given the program count.
  init(programs: [Program], offset: Int = 0) {
    self.programs = programs
    self.offset   = offset
  }

  // Program count in the group.
  var count: Int {
    return programs.count
  }

  // Returns a program's position given its index.
  func index(_ position: Position) -> Int {
    return (position.at + offset) ÷ count
  }

  // Returns a program's index given its position.
  func position(_ i: Int) -> Position {
    return Position(at: (i - offset) ÷ count)
  }

  // Returns the index of the given program.
  func index(_ program: Program) -> Int {
    return programs.index(of: program)!
  }

  // Returns the position of the given program.
  func position(_ program: Program) -> Position {
    return position(index(program))
  }

  // Swap the programs at indices i and j.
  func swaped(_ i: Int, _ j: Int) -> [Program] {
    var programs = self.programs
    (programs[i], programs[j]) = (programs[j], programs[i])
    return programs
  }

  // Display the programs in their ascending position order.
  public var description: String {
    return String(programs.sorted(by: { position($0).at < position($1).at }))
  }

  // Represent a serie of move to be performed a number of times.
  public class Tune {
    let moves: [Move]
    let times: Int

    // Create a tune from a string description of moves.
    public convenience init(_ song: String) {
      let moves = song.split(separator: ",").map { Move.parse(String($0))! }
      self.init(moves: moves)
    }

    // Create a tune given its serie of moves and the repetition count.
    init(moves: [Move], times: Int = 1) {
      self.moves = moves
      self.times = times
    }

    // Returns a new tune that is the given one repeated n times.
    public static func ♯ (to_repeat: Tune, n: Int) -> Tune {
      return Tune(moves: to_repeat.moves, times: n * to_repeat.times)
    }

    // Make the given group dance to the provided tune.
    @discardableResult
    public static func ♫ (dancers: PermutationPromenade, tune: Tune) -> PermutationPromenade {
      var dancers = dancers
      var memoized: [String: Int] = [:]
      for time in 0..<tune.times {
        for move in tune.moves {
          dancers = dancers ♪ move
        }
        // NOTE: shortcut the dance if we can. If we've already seen this
        // position from a previous iteration we've detected a loop. We can
        // then avoid to loop and only dance the remaining time to reach the
        // final position.
        let position = "\(dancers)"
        if let seen = memoized[position] {
          let size = time - seen // the loop size
          let left = tune.times - time - 1 // # of iteration left to do
          let reminder = left ÷ size // # of iteration left to do after the loop
          // Make the dancer perform the moves only reminder times.
          return dancers ♫ Tune(moves: tune.moves) ♯ reminder
        }
        memoized[position] = time
      }
      // here we've made the dancer do the moves the total requested number of
      // times.
      return dancers
    }
  }

  // Newtype Int to represent a program's position. This way the typechecker
  // compel us to translate a position into an index before accessing a
  // program.
  struct Position { let at: Int }

  // Represent a dance move.
  enum Move {
    static let RE = ( // parsing stuff
      spin:     Regex("s([0-9]+)"),
      exchange: Regex("x([0-9]+)/([0-9]+)"),
      partner:  Regex("p([a-z])/([a-z])"))

    case spin(Int)
    case exchange(Position, Position)
    case partner(Program, Program)

    // Parse a move string.
    static func parse(_ s: String) -> Move? {
      if let match = Move.RE.spin.firstMatch(in: s) {
        let size = Int(match.captures[0]!)!
        return .spin(size)
      }
      if let match = Move.RE.exchange.firstMatch(in: s) {
        let p = Position(at: Int(match.captures[0]!)!)
        let q = Position(at: Int(match.captures[1]!)!)
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
