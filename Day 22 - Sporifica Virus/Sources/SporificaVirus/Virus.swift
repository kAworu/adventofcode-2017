// infection operator (skull and crossbones),
// see https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols#Health_and_safety
infix operator ☠  : AdditionPrecedence

extension SporificaVirus {
  // Teh Sporifica Virus.
  public class Virus {
    // The virus generation.
    public enum Generation {
      case first, evolved

      // Returns the new status of a node in the initial given status after the
      // infection from a virus of this generation.
      static func ☠  (agent: Generation, victim: Grid.Status) -> Grid.Status {
        switch (agent, victim) {
          case (.first, .infected):   return .clean
          case (.first, _):           return .infected
          case (.evolved, .clean):    return .weakened
          case (.evolved, .weakened): return .infected
          case (.evolved, .infected): return .flagged
          case (.evolved, .flagged):  return .clean
        }
      }
    }

    var heading: Grid.Heading
    var position: Grid.Point
    let generation: Generation

    // Create a virus.
    init(heading: Grid.Heading, position: Grid.Point, generation: Generation) {
      self.heading    = heading
      self.position   = position
      self.generation = generation
    }

    // Return the new status for the current position.
    func burst(in grid: Grid) -> Grid.Status {
      var status = grid[position] // the current node status
      // Virus action depending on the current node status.
      switch status {
        case .clean:
          heading = heading.left
        case .infected:
          heading = heading.right
        case .flagged:
          heading = heading.opposite
        case .weakened: // do not turn
          break
      }
      // Update the current node status.
      status = self.generation ☠  status
      grid[position] = status
      // Finally, the virus move forward.
      position = position[heading]
      // We're done, return the new status.
      return status
    }
  }
}
