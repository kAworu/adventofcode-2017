import Regex

// The program tower.
public class RecursiveCircus {
  let programs: Set<Program>

  // Create a new tower, given a program per line.
  convenience init?(_ list: String) {
    let lines = list.split(separator: "\n").map(String.init)
    self.init(lines)
  }

  // Create a new tower from a list of program description.
  public init?(_ lines: [String]) {
    var programs: [String: Program]  = [:] // name to Program dict
    var children: [String: [String]] = [:] // name to children names dict
    // First pass: build all the programs populating only their name and weight
    // members (ignoring relationships for now).
    for line in lines {
      guard let match = Program.LINE_REGEX.firstMatch(in: line) else { return nil }
      let (name, weight_str, children_str) = (
        match.captures[0]!,
        match.captures[1]!,
        match.captures[2]!
      )
      programs[name] = Program(name: name, weight: Int(weight_str)!)
      children[name] = Program.NAME_REGEX.allMatches(in: children_str).map {
        $0.matchedString
      }
    }
    // Second pass: build the parent → child relationships
    for parent in programs.values {
      for child_name in children[parent.name]! {
        guard let child = programs[child_name] else { return nil }
        parent → child
      }
    }
    // we're done
    self.programs = Set(programs.values)
  }

  // Returns the "root" program of this tower (if any).
  public var bottom_program: Program? {
    return programs.first(where: { $0.is_parent && !$0.is_child })
  }
}

// parent to child relationship operator
infix operator →: ComparisonPrecedence

// Represents a program from the tower.
public class Program {
  static let LINE_REGEX = Regex("([a-z]+) \\(([0-9]+)\\)(.*)?")
  static let NAME_REGEX = Regex("[a-z]+")

  // Create a parent to child relationship. Returns `child` to allow chaining.
  @discardableResult static func →(parent: Program, child: Program) -> Program {
    parent.children.insert(child)
    child.parent = parent
    return child
  }

  let name: String
  let weight: Int
  var parent: Program?
  var children: Set<Program>

  // Create a new program without parent nor children.
  init(name: String, weight: Int) {
    self.name     = name
    self.weight   = weight
    self.parent   = nil
    self.children = []
  }

  // Returns true if this program has at least one child, false otherwise.
  var is_parent: Bool {
    return !children.isEmpty
  }

  // Returns true if this program has a parent, false otherwise.
  var is_child: Bool {
    return parent != nil
  }

  // Returns the weight of this program and all programs above it iff it is
  // balanced, throws a `ProgrammingError.invalidWeight` otherwise.
  public func total_weight() throws -> Int {
    // this will throw if any program above self is unbalanced.
    let weights = try Dictionary(grouping: children, by: {
      try $0.total_weight()
    })
    // Here all our children are balanced themselves. If we have no children or
    // all have the same weight, then we are balanced too.
    if weights.count < 2 {
      return weights.reduce(self.weight) { acc, element in
        return acc + element.key * element.value.count
      }
    }
    // Here we are unbalanced. The child needing a correction (the culprit) is
    // the sole of our children having a different total_weight than the
    // others. In our grouping it is the one alone for its total_weight, i.e.
    // the entry in `weights` having the minimum (only one) program as value.
    let min     = weights.min(by: { $0.value.count < $1.value.count })!
    let max     = weights.max(by: { $0.value.count < $1.value.count })!
    let culprit = min.value.first!  // min.value is an array of size 1 here
    let delta   = max.key - min.key // keys are total_weight in our grouping
    throw InvalidWeightError(culprit: culprit, delta: delta)
  }
}

// see Program.total_weight()
public class InvalidWeightError: Error {
  public let culprit: Program
  let delta: Int

  init(culprit: Program, delta: Int) {
    self.culprit = culprit
    self.delta   = delta
  }

  // Returns the corrected weight of our culprit.
  public var corrected_weight: Int {
    return culprit.weight + delta
  }
}

// "delegate" hashValue, == and String conversion to the Program's name and
// expose them.

extension Program: Hashable {
  public var hashValue: Int {
    return name.hashValue
  }

  // NOTE: assume that there are no two programs with the same name.
  public static func ==(lhs: Program, rhs: Program) -> Bool {
    return lhs.name == rhs.name
  }
}

extension Program: CustomStringConvertible {
  public var description: String {
    return name
  }
}
