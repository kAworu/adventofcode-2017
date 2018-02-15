extension CoprocessorConflagration {
  // The scary, experimental, hard-working coprocessor.
  public class CoProcessor {
    let program: Assembly                  // the program to execute.
    var registers: [Register: Int] = [:]   // the processor's registers.
    let default_value: Int = 0             // default register value.
    var pc: Int = 0                        // program counter.
    public private(set) var usage: [String: Int] = [:] // instructions stats.

    // Create a new processor given its id. The Processor.ID_REGISTER will be
    // initially set to the processor id.
    public init(program: Assembly) {
      self.program = program
    }

    // Execute the program on this processor.
    public func run() {
      while let current = instruction {
        execute(current)
        advance()
      }
    }

    // Execute a given instruction on this processor.
    func execute(_ instruction: Assembly.Instruction) {
      // syntaxic sugar to evaluate an Expression.
      func eval(_ expression: Assembly.Instruction.Expression) -> Int {
        return expression.eval(fetch: { self[$0] })
      }
      switch instruction {
        case .set(let reg, let exp):
          self[reg] = eval(exp)
        case .sub(let reg, let exp):
          self[reg] = self[reg] - eval(exp)
        case .mul(let reg, let exp):
          self[reg] = self[reg] * eval(exp)
        case .jnz(let cond, let offset):
          if eval(cond) != 0 {
            // NOTE: minus one because the pc will be advanced by one after the jump
            // instruction execution.
            pc += Int(eval(offset) - 1)
          }
      }
      usage["\(instruction)", default: 0] += 1
    }

    // Advance the program counter.
    func advance() {
      pc += 1
    }

    // The instruction to be executed by the CPU, if any.
    var instruction: Assembly.Instruction? {
      // Check against zero just to be sure, (e.g. bad jump).
      guard (0..<program.instructions.count).contains(pc) else { return nil }
      return program.instructions[pc]
    }

    // Shortcut to get & set registers, honoring the configured default value
    // when a register has none.
    subscript(_ reg: Register) -> Int {
      get {
        return registers[reg, default: default_value]
      }
      set(newValue) {
        registers[reg] = newValue
      }
    }
  }

  // Syntaxic sugar for register names.
  typealias Register = Character
}
