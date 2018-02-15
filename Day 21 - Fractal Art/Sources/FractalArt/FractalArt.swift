import Regex

// The artist's chef-d'œuvre.
public class FractalArt {
  // Parsing stuff.
  private static let RE = Regex("([./#]+) => ([./#]+)")

  // Parse a single enhancement rule. Returns a tuple of grid describing the
  // enhancement rule, or nil on parsing failure.
  private static func parse_rule(_ s: String) -> (grid: Grid, enhanced: Grid)? {
    guard let match  = FractalArt.RE.firstMatch(in: s) else { return nil }
    guard let input  = Grid(match.captures[0]!) else { return nil }
    guard let output = Grid(match.captures[1]!) else { return nil }
    return (grid: input, enhanced: output)
  }

  // Parse many enhancement rules. Returns a dictionary of grid to their
  // enhanced form taking rotations and flip into account (a single rule will
  // always have to same enhanced result but can accept multiple different grid
  // as input).
  private static func parse_rules(_ patterns: [String]) -> [Grid: Grid]? {
    var rules: [Grid: Grid] = [:]
    for p in patterns {
      guard let (grid, enhanced) = FractalArt.parse_rule(p) else { return nil }
      for variation in grid.transformations() {
        rules[variation] = enhanced
      }
    }
    return rules
  }

  public let grid: Grid
  let rules: [Grid: Grid]

  // Create a fractal given a set of rule and its initial grid. Returns nil on
  // rule parsing failure.
  public init?(rules xs: [String], grid: Grid = .glider) {
    guard let rules = FractalArt.parse_rules(xs) else { return nil }
    self.rules = rules
    self.grid = grid
  }

  // Returns the initial grid enhanced a given number of times.
  public func enhance(times: Int = 1) -> Grid {
    var grid = self.grid // start with this fractal's initial grid.
    for _ in 0..<times {
      grid = grid.enhanced(by: rules)
    }
    return grid
  }
}
