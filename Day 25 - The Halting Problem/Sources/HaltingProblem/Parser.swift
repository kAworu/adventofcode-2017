import Regex

// BluePrint parser stuff.
extension HaltingProblem.BluePrint {

  // Used to parse a blueprint string description into a full BluePrint object.
  class Parser {
    // We need incomplete block and state representation because the block
    // references their transition state. The incomplete rep. store the block
    // not linked yet along with the state name they should reference. Only
    // once all states are created the blocks can be "linked".
    typealias IncompleteBlock = (block: State.Block, next: State.Name)
    typealias IncompleteState = (
      name: State.Name, blocks: (IncompleteBlock, IncompleteBlock)
    )
    typealias IncompleteStateDict = [State.Name: IncompleteState]

    // Regular expression detecting a blank line. This is needed because
    // blueprint description may have blank lines.
    private static let BLANK_LINE_RE = Regex("^\\s*$")

    // All the statements
    private var statements: [Statement]
    // Last statement returned by pop().
    private var poped: Statement? = nil

    // Create a parser from a blueprint description string.
    convenience init(blueprint: String) {
      let lines = blueprint.split(separator: "\n").map(String.init)
      self.init(lines)
    }

    // Create a parser from a blueprint description string.
    private init(_ lines: [String]) {
      self.statements = lines.enumerated().map {
        Statement.parse(desc: $0.element, lineno: $0.offset + 1)
      }
    }

    // Parse and return the BluePrint. Throws all sort of parsing errors.
    func blueprint() throws -> HaltingProblem.BluePrint {
      // First two lines should be the blueprint preamble.
      let (initial_name, steps) = try parse_preamble()
      // Build the incomplete states while there are statement left to process.
      var incomplete: IncompleteStateDict = [:]
      while !statements.isEmpty {
        let state = try parse_state()
        incomplete[state.name] = state
      }
      // Complete the states now that they are all unwrapped.
      let states = try self.complete(incomplete)
      if let initial = states[initial_name] {
        return HaltingProblem.BluePrint(initial: initial, steps: steps, states: states)
      } else {
        throw MissingStateError(name: initial_name, ref: nil)
      }
    }

    // Complete a dictionary of incomplete states returning the result. Throws
    // MissingStateError when a referenced state could not be found.
    func complete(_ incomplete: IncompleteStateDict) throws -> StateDict {
      // Simply create the states, references will be completed in a second
      // pass.
      var states: StateDict = [:]
      for istate in incomplete.values {
        let blocks = (istate.blocks.0.block, istate.blocks.1.block)
        let state = State(name: istate.name, blocks: blocks)
        states[state.name] = state
      }
      // Now build the transition references.
      for state in states.values {
        let (iblock0, iblock1) = incomplete[state.name]!.blocks
        guard let next0 = states[iblock0.next] else {
          throw MissingStateError(name: iblock0.next, ref: state)
        }
        state.blocks.0.next = next0
        guard let next1 = states[iblock1.next] else {
          throw MissingStateError(name: iblock1.next, ref: state)
        }
        state.blocks.1.next = next1
      }
      // We're done.
      return states
    }

    // Parse the initial state and the number of steps to perform before
    // running a diagnostic checksum.
    private func parse_preamble() throws -> (initial: State.Name, steps: Int) {
      // Helper to unwrap the intial state.
      func unwrap_initial() throws -> State.Name {
        return try unwrap("Begin in <state>") {
          if case .begin_in(let state) = $0 {
            return state
          } else {
            return nil
          }
        }
      }
      // Helper to unwrap the step count.
      func unwrap_steps() throws -> Int {
        return try unwrap("Perform a diagnostic checksum after <n> steps.") {
          if case .checksum(let n) = $0 {
            return n
          } else {
            return nil
          }
        }
      }
      let state = try unwrap_initial()
      let n = try unwrap_steps()
      return (initial: state, steps: n)
    }

    // Parse and return exactly one state.
    private func parse_state() throws -> IncompleteState {
      // Helper to unwrap the state's name from the first line of the
      // definition.
      func unwrap_name() throws -> State.Name {
        return try unwrap("In state <state>:") {
          if case .define(let name) = $0 {
            return name
          } else {
            return nil
          }
        }
      }
      // Helper to unwrap a state condition block value.
      func unwrap_condition() throws -> Value {
        return try unwrap("If the current value is <value>:") {
          if case .if_the_current_value_is(let val) = $0 {
            return val
          } else {
            return nil
          }
        }
      }
      // Helper to unwrap a value write statement.
      func unwrap_write() throws -> Value {
        return try unwrap("- Write the value <value>.") {
          if case .write(let val) = $0 {
            return val
          } else {
            return nil
          }
        }
      }
      // Helper to unwrap a cursor move statement.
      func unwrap_move() throws -> Direction {
        return try unwrap("- Move one slot to the <direction>.") {
          if case .move_one_slot(let direction) = $0 {
            return direction
          } else {
            return nil
          }
        }
      }
      // Helper to unwrap a state transition statement.
      func unwrap_next() throws -> State.Name {
        return try unwrap("- Continue with state <state>.") {
          if case .continue_with(let next) = $0 {
            return next
          } else {
            return nil
          }
        }
      }
      // Helper to unwrap a block, i.e. a condition for the given expected
      // value followed by a write, move, and next state transition.
      func unwrap_block(expect: Value) throws -> IncompleteBlock {
        let cond = try unwrap_condition()
        if cond != expect {
          throw WrongConditionError(expected: expect, got: self.poped!)
        }
        let write = try unwrap_write()
        let direction = try unwrap_move()
        let next = try unwrap_next()
        let block = State.Block(write: write, direction: direction)
        return IncompleteBlock(block: block, next: next)
      }
      // NOTE: the first block is consistently the block for the .zero value.
      let name   = try unwrap_name()
      let block0 = try unwrap_block(expect: .zero)
      let block1 = try unwrap_block(expect: .one)
      return IncompleteState(name: name, blocks: (block0, block1))
    }

    // Helper to extract the parsed data from a statement.
    //
    // Because a statement include metadata along with the token enum value
    // parsed (i.e. parsed line, line number etc.) it can be cumbersome to
    // simply check if it is the expected type of statement and get its
    // variables. This function make it a bit easier by providing a simple
    // interface managing the error handling.
    //
    // @param desc: description string of what we're trying to unwrap. Used to
    // build errors.
    //
    // @param accept: closure taking the statement's token as argument and
    // returning the result on success, nil on failure.
    //
    // @throws EndOfInputError if there are no statement left to analyze.
    // @throws ParseError if the accept closure returned nil.
    private func unwrap<R>(_ desc: String, accept: (Statement.Token) -> R?)
    throws -> R {
      let statement = try pop(parsing: desc)
      if let result = accept(statement.token) {
        return result
      } else {
        throw ParseError(expected: desc, got: statement)
      }
    }

    // Remove and return the first statement from the list. Throws an
    // EndOfInputError if there are no statement left.
    private func pop(parsing: String) throws -> Statement {
      if self.statements.isEmpty {
        throw EndOfInputError(expected: parsing)
      }
      self.poped = self.statements.removeFirst()
      return self.poped!
    }

    // Represent a blueprint line statement. Hold the source line and line
    // number for debugging and error reporting.
    struct Statement {
      // Represents the parsed line and its variable.
      enum Token {
        // parsing stuff.
        private static let BEGIN_RE     = Regex("Begin in state ([A-Za-z]+)\\.")
        private static let CHECKSUM_RE  = Regex("Perform a diagnostic checksum after ([0-9]+) steps\\.")
        private static let DEFINE_RE    = Regex("In state ([A-Za-z]+):")
        private static let CONDITION_RE = Regex("If the current value is (0|1):")
        private static let WRITE_RE     = Regex("- Write the value (0|1)\\.")
        private static let MOVE_RE      = Regex("- Move one slot to the (left|right).")
        private static let CONTINUE_RE  = Regex("- Continue with state ([A-Za-z]+)\\.")

        // Token types
        case begin_in(state: State.Name)
        case checksum(steps: Int)
        case define(state: State.Name)
        case if_the_current_value_is(Value)
        case write(value: Value)
        case move_one_slot(to: Direction)
        case continue_with(state: State.Name)
        case invalid

        // Parse a given string into a token. On failure, .invalid is returned.
        static func tokenize(_ s: String) -> Token {
          if let match = Token.BEGIN_RE.firstMatch(in: s) {
            let state = State.Name(match.captures[0]!)
            return .begin_in(state: state)
          } else if let match = Token.CHECKSUM_RE.firstMatch(in: s) {
            let steps = Int(match.captures[0]!)!
            return .checksum(steps: steps)
          } else if let match = Token.DEFINE_RE.firstMatch(in: s) {
            let state = State.Name(match.captures[0]!)
            return .define(state: state)
          } else if let match = Token.CONDITION_RE.firstMatch(in: s) {
            let value = Value(rawValue: Int(match.captures[0]!)!)!
            return .if_the_current_value_is(value)
          } else if let match = Token.WRITE_RE.firstMatch(in: s) {
            let value = Value(rawValue: Int(match.captures[0]!)!)!
            return .write(value: value)
          } else if let match = Token.MOVE_RE.firstMatch(in: s) {
            let direction = Direction(rawValue: match.captures[0]!)!
            return .move_one_slot(to: direction)
          } else if let match = Token.CONTINUE_RE.firstMatch(in: s) {
            let state = State.Name(match.captures[0]!)
            return .continue_with(state: state)
          } else {
            return .invalid
          }
        }
      }

      let token: Token
      let line: String
      let number: Int

      // Create a statement given its members.
      private init(token: Token, line: String, number: Int) {
        self.token  = token
        self.line   = line
        self.number = number
      }

      // Parse a given string into a statement. The lineno (line number) is
      // used to build the statement for later use. On failure, a statement
      // with the .invalid token is returned.
      static func parse(desc: String, lineno: Int) -> Statement {
        let token = Token.tokenize(desc)
        return Statement(token: token, line: desc, number: lineno)
      }
    }

    // Generic error thrown when parsing failed. See unwrap().
    struct ParseError: Error, CustomStringConvertible {
      let expected: String
      let got: Statement

      var description: String {
        let number = got.number
        let line   = got.line
        return "expected `\(expected)` on line \(number): \(line)"
      }
    }

    // Error thrown when there are no statement left while one was needed.
    // See pop().
    struct EndOfInputError: Error, CustomStringConvertible {
      let expected: String

      var description: String {
        return "end of input when expecting: \(expected)"
      }
    }

    // Error thrown when a block condition value was not in the right order.
    // see parse_state().
    struct WrongConditionError: Error, CustomStringConvertible {
      let expected: Value
      let got: Statement

      var description: String {
        let number = got.number
        let line   = got.line
        return "expected condition block for \(expected) on line \(number): \(line)"
      }
    }

    // Error thrown when a block reference a state that is not defined by the
    // blueprint. See blueprint() and complete().
    struct MissingStateError: Error, CustomStringConvertible {
      let name: State.Name
      let ref: State?

      var description: String {
        var ref_by = "Begin in"
        if let state = ref {
          ref_by = "state \(state.name)"
        }
        return "state named \(name) referred by \(ref_by) is missing"
      }
    }
  }
}
