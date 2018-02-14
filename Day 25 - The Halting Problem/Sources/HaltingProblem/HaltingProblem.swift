public class HaltingProblem {
  let blueprint: BluePrint

  // Create a machine given its blueprint. Throws if parsing the given
  // blueprint description failed.
  public init(blueprint desc: String) throws {
    let parser = BluePrint.Parser(blueprint: desc)
    self.blueprint = try parser.blueprint()
  }

  // Run the blueprint on a new tape and return the tape.
  public func run() -> Tape {
    let tape = Tape()
    blueprint.execute(on: tape)
    return tape
  }

  // Represents a machine's tape and hold the cursor.
  public class Tape {
    var memory: [Int: BluePrint.Value] = [:]
    var cursor: Int = 0

    // Move the cursor to the given direction on this tape.
    func move(direction: BluePrint.Direction) {
      cursor += (direction == .left ? -1 : +1)
    }

    // get / set the tape's value under its cursor.
    var current: BluePrint.Value {
      get {
        return memory[cursor] ?? .zero
      }
      set(newValue) {
        memory[cursor] = newValue
      }
    }

    // Returns the diagnostic checksum of this tape.
    public func checksum() -> Int {
      return memory.values.map { $0.rawValue }.reduce(0, +)
    }
  }
}
