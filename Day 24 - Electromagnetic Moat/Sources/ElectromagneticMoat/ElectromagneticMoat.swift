// A magnetic bridge solver.
public class ElectromagneticMoat {
  // All the components available.
  let components: Set<Bridge.Component>

  // Create a bridge solver from a list of component descriptions. Returns nil
  // if any component failed to be parsed.
  public init?(components xs: [String]) {
    var components: Set<Bridge.Component> = []
    for (i, s) in xs.enumerated() {
      guard let c = Bridge.Component(id: i, desc: s) else { return nil }
      components.insert(c)
    }
    self.components = components
  }

  // Returns the strongest bridge that can be built using the available
  // components.
  public func strongest() -> Bridge {
    return strongest_and_longest().strongest
  }

  // Returns the longest bridge that can be built using the available
  // components. If multiple bridges have the longest length the strongest one
  // is returned.
  public func longest() -> Bridge {
    return strongest_and_longest().longest
  }

  // Returns a tuple of the strongest and longest bridges.
  public func strongest_and_longest() -> (strongest: Bridge, longest: Bridge) {
    return self.reduce((strongest: Bridge.pit, longest: Bridge.pit)) {
      (
        strongest: $0.strongest.is_stronger(than: $1) ? $0.strongest : $1,
        longest: $0.longest.is_longer(than: $1) ? $0.longest : $1
      )
    }
  }

  // "Standard" reduce() function over all the bridges that can be built using
  // the available components of this solver.
  private func reduce<Result>(_ initial: Result, _ next: (Result, Bridge) -> Result) -> Result {
    var result = initial
    // A simple DFS algorithm using the `candidates` stack composed of the
    // current bridge built so far and the remaining available components.
    var candidates = [(bridge: Bridge.pit, available: components)]
    while let (bridge, available) = candidates.popLast() {
      result = next(result, bridge)
      for component in available {
        // check if we can extend the current bridge with this component.
        if let extended = bridge.extended(with: component) {
          let remaining = available.subtracting([component])
          candidates.append((bridge: extended, available: remaining))
        }
      }
    }
    return result
  }
}
