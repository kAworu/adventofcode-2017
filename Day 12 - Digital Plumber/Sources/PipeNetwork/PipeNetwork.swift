import Regex

// Program pipe relationship operator (left right arrow).
infix operator ↔ : ComparisonPrecedence

// The programs pipe network.
public class PipeNetwork {
  public typealias Id = UInt // Program ID type

  let programs: Set<Program>

  // Create a network, given a program per line. Returns nil if parsing failed.
  public convenience init?(_ list: String) {
    let lines = list.split(separator: "\n").map(String.init)
    self.init(lines)
  }

  // Create a network from an array of program description. Returns nil if any
  // line could not be parsed successfully.
  public init?(_ lines: [String]) {
    var programs: [Id: Program] = [:] // ID to Program dict
    var neighbours: [Id: [Id]]  = [:] // ID to neighbours ID dict
    // First pass: build all the programs populating only their ID members
    // (ignoring the pipes for now).
    for line in lines {
      guard let match = Program.RE.line.firstMatch(in: line) else { return nil }
      let (id, neighbours_str) = (Id(match.captures[0]!)!, match.captures[1]!)
      programs[id]   = Program(id)
      neighbours[id] = Program.RE.id.allMatches(in: neighbours_str).map {
        Id($0.matchedString)!
      }
    }
    // Second pass: build the pipes ↔ relationships
    for program in programs.values {
      for neighbour_id in neighbours[program.id]! {
        guard let neighbour = programs[neighbour_id] else { return nil }
        program ↔ neighbour
      }
    }
    // we're done
    self.programs = Set(programs.values)
  }

  // Find a program by ID.
  public subscript(program pid: Id) -> Program? {
    return programs.first(where: { $0.id == pid })
  }

  // Returns the Set of the different program groups.
  public func groups() -> Set<Set<Program>> {
    var groups: Set<Set<Program>> = []
    var to_visit = self.programs
    while let program = to_visit.popFirst() {
      let g = program.group()
      groups.insert(g)
      to_visit ∖= g
    }
    return groups
  }

  // Represents a program from the pipe network.
  public class Program: Hashable {
    static let RE = (
      line: Regex("([0-9]+) <-> (.+)"),
      id:   Regex("[0-9]+")
    )

    // Create a pipe between two given programs.
    static func ↔ (lhs: Program, rhs: Program) {
      lhs.neighbours.insert(rhs)
      rhs.neighbours.insert(lhs)
    }

    // Compare two given programs for equality.
    // NOTE: assume that no two programs have the same id.
    public static func == (lhs: Program, rhs: Program) -> Bool {
      return lhs.id == rhs.id
    }

    let id: Id
    var neighbours: Set<Program> = []

    // Create a new program without parent nor children.
    init(_ id: Id) {
      self.id = id
      self ↔ self // connect this program to itself.
    }

    // Returns the Set of all the programs connected to this program through a
    // pipe (including self).
    public func group() -> Set<Program> {
      var to_visit: Set<Program> = [self]
      var visited: Set<Program>  = []
      while let program = to_visit.popFirst() {
        visited.insert(program)
        // NOTE: avoid visiting a program twice.
        to_visit ∪= program.neighbours.filter { !visited.contains($0) }
      }
      return visited
    }

    // Conform to Hashable.
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }
}

// Set union operator, syntaxic sugar for Set.union(_:)
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Sets
infix operator ∪ : AdditionPrecedence
// Compound assignment Set union operator, syntaxic sugar for Set.formUnion(_:)
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Sets
infix operator ∪= : AssignmentPrecedence
// Set difference operator, syntaxic sugar for Set.subtracted(_:)
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Sets
// and https://en.wikipedia.org/wiki/Complement_(set_theory)
infix operator ∖ : AdditionPrecedence
// Compound assignment Set union operator, syntaxic sugar for Set.formUnion(_:)
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Sets
infix operator ∖= : AssignmentPrecedence

extension Set {
  static func ∪(lhs: Set, rhs: Set) -> Set {
    return lhs.union(rhs)
  }

  static func ∪=(lhs: inout Set, rhs: Set) {
    lhs.formUnion(rhs)
  }

  static func ∖(lhs: Set, rhs: Set) -> Set {
    return lhs.subtracting(rhs)
  }

  static func ∖=(lhs: inout Set, rhs: Set) {
    lhs.subtract(rhs)
  }
}
