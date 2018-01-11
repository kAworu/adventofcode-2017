import Regex

// Modulo operator based on swift's reminder (%) operator.
infix operator ÷ : MultiplicationPrecedence
func ÷ (x: Int, m: Int) -> Int {
  let r = x % m
  return (r < 0 ? r + m : r)
}

// Our group of dancing programs.
// NOTE: We use a double dictionary as internal representation so that both
// Exchange and Partner moves can be performed in O(1). Additionally we keep
// track of an offset instead of updating all program positions so that
// performing a Spin is also O(1).
public class PermutationPromenade {
  typealias Program = Character

  // Newtype Int to represent a program's position. This way the typechecker
  // compel us to translate a position into an index before accessing a
  // program.
  struct Position { let at: Int }

  var offset: Int = 0 // used to translate Position from/to index
  var programs: [Int: Program] = [:] // index to program name
  var indices: [Program: Int] = [:] // program name to index

  // Create a new group given the program count.
  public init(count: Int) {
    let a = Int("a".utf8.first!) // 97
    for i in 0..<count {
      let program = Program(UnicodeScalar(a + i)!)
      programs[i] = program
      indices[program] = i
    }
  }

  // Make the group dance a tune (moves separated by comma).
  public func dance(tune: String) {
    let moves = tune.split(separator: ",").map { Move.parse(String($0))! }
    for move in moves {
      dance(move)
    }
  }

  // Make the group dance a single move.
  func dance(_ move: Move) {
    switch move {
      case .spin(let size):
        // NOTE: a Spin moves programs *from the end to the front*, hence the
        // substraction (offset moves "backward").
        offset = (offset - size) ÷ programs.count
      case .exchange(let p, let q):
        swap(index(p), index(q))
      case .partner(let a, let b):
        swap(index(a), index(b))
    }
  }

  // Swap the programs at indices i and j.
  func swap(_ i: Int, _ j: Int) {
    let (a, b) = (programs[i]!, programs[j]!)
    (programs[i], programs[j]) = (b, a)
    (indices[a],  indices[b])  = (j, i)
  }

  // Returns a program's position given its index.
  func index(_ position: Position) -> Int {
    return (position.at + offset) ÷ programs.count
  }

  // Returns a program's index given its position.
  func position(_ i: Int) -> Position {
    let n = programs.count
    return Position(at: (i - offset) ÷ n)
  }

  // Returns the index of the given program.
  func index(_ program: Program) -> Int {
    return indices[program]!
  }

  // Returns the position of the given program.
  func position(_ program: Program) -> Position {
    return position(index(program))
  }

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

// Display the programs in their ascending position order.
extension PermutationPromenade: CustomStringConvertible {
  public var description: String {
    let chars = programs.map { $0.value }
    return String(chars.sorted(by: { position($0) < position($1) }))
  }
}

// "delegate" position comparison to their underlying Int.
extension PermutationPromenade.Position: Comparable {
  static func < (lhs: PermutationPromenade.Position, rhs: PermutationPromenade.Position) -> Bool {
    return lhs.at < rhs.at
  }
  static func == (lhs: PermutationPromenade.Position, rhs: PermutationPromenade.Position) -> Bool {
    return lhs.at == rhs.at
  }
}
