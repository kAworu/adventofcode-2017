extension HaltingProblem {
  // Represents the Turing machine blueprint found in a bearby pile of debris.
  struct BluePrint {
    // State name to state dictionary.
    typealias StateDict = [State.Name: State]

    // the name of the state we begin in.
    let initial: State.Name
    // the step count to perform before performing a diagnostic checksum.
    let steps: Int
    // All the states.
    let states: StateDict

    // Execute this blueprint on the given tape.
    func execute(on tape: HaltingProblem.Tape) {
      var state = states[initial]!
      for _ in 1...steps {
        let name = state.execute(on: tape)
        state = states[name]!
      }
    }

    // Represent a value that can be read or written by the blueprint.
    enum Value: Int {
      case zero = 0
      case one  = 1
    }

    // Represent a direction in which the blueprint may move the machine's
    // cursor.
    enum Direction: String {
      case left  = "left"
      case right = "right"
    }

    // Represent a blueprint state.
    struct State {
      typealias Name = String

      let name: Name
      let blocks: (Block, Block)

      // Get the block that should be executed for the given value.
      private subscript(value: Value) -> Block {
        return value == .zero ? blocks.0 : blocks.1
      }

      // Execute this state on the given tape and return the state name that
      // should be transitioned into.
      func execute(on tape: Tape) -> Name {
        let block = self[tape.current]
        tape.current = block.write
        tape.move(direction: block.direction)
        return block.next
      }

      // Hold the state's actions (write, move) and the next state to
      // transition into.
      struct Block {
        let write: Value
        let direction: Direction
        let next: Name
      }
    }
  }
}
