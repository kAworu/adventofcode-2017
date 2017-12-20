import Regex

public class RecursiveCircus {
  let programs: [String: Program]

  convenience init?(_ list: String) {
    let lines = list.split(separator: "\n").map(String.init)
    self.init(lines.filter { !$0.isEmpty })
  }

  public init?(_ lines: [String]) {
    var programs: [String: Program]  = [:] // name to Program dict
    var children: [String: [String]] = [:] // name to children names dict

    // first pass, build all Program populating their name and weight
    // properties.
    for line in lines {
      guard let match = Program.LINE_REGEX.firstMatch(in: line) else {
        return nil
      }
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

  // second pass, build the parent → child relationships
    for parent in programs.values {
      for child_name in children[parent.name]! {
        guard let child = programs[child_name] else {
          return nil
        }
        parent → child
      }
    }

    // we're done
    self.programs = programs
  }

  public var bottom_program: String? {
    // start with a random program and traverse the tree until we find the
    // root program.
    guard var p = programs.first?.value else {
      return nil
    }
    while p.is_child {
      p = p.parent!
    }
    return p.name
  }
}

// parent to child relationship operator
infix operator →: ComparisonPrecedence

class Program {
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

  init(name: String, weight: Int) {
    self.name     = name
    self.weight   = weight
    self.parent   = nil
    self.children = []
  }

  var is_parent: Bool {
    return !children.isEmpty
  }

  var is_child: Bool {
    return parent != nil
  }
}

// delegate hashValue and == to the Program's name
extension Program: Hashable {
  var hashValue: Int {
    return name.hashValue
  }

  static func ==(lhs: Program, rhs: Program) -> Bool {
    return lhs.name == rhs.name
  }
}
