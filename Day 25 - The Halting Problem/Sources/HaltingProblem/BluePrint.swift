extension HaltingProblem {
  // Represents the Turing machine blueprint found in a bearby pile of debris.
  class BluePrint {
    // State name to state dictionary.
    typealias StateDict = [State.Name: State]

    // the state we begin in.
    let initial: State
    // the step count to perform before performing a diagnostic checksum.
    let steps: Int
    // All the states.
    let states: StateDict

    // Create a blueprint given its members.
    init(initial: State, steps: Int, states: StateDict) {
      self.initial = initial
      self.steps   = steps
      self.states  = states
    }

    // Execute this blueprint on the given tape.
    func execute(on tape: HaltingProblem.Tape) {
      var state = initial
      for _ in 1...steps {
        state = state.execute(on: tape)
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
    class State {
      typealias Name = String

      let name: Name
      var blocks: (Block, Block)

      // Create a state given its members.
      init(name: Name, blocks: (Block, Block)) {
        self.name   = name
        self.blocks = blocks
      }

      // Get the block that should be executed for the given value.
      private subscript(value: Value) -> Block {
        return value == .zero ? blocks.0 : blocks.1
      }

      // Execute this state on the given tape and return the new state.
      func execute(on tape: Tape) -> State {
        let block = self[tape.current]
        tape.current = block.write
        tape.move(direction: block.direction)
        return block.next!
      }

      // Hold the state's actions (write, move) and the next state to
      // transition into.
      class Block {
        let write: Value
        let direction: Direction
        weak var next: State? = nil

        // Create a block. It is expected that the next state should be defined
        // after this constructor return.
        init(write: Value, direction: Direction) {
          self.write = write
          self.direction = direction
        }
      }
    }
  }
}
