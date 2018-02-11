import Regex

// CPU and code, a hacked version of Day 18.
public class CoprocessorConflagration {
  // Syntaxic sugar for register names.
  typealias Register = Character

  // The tablet's assembly code variante run by the coprocessor.
  public class Assembly {
    // An code instruction
    enum Instruction: CustomStringConvertible {
      // Either an integer or a register name.
      enum Expression {
        case literal(Int)
        case identifier(Register)

        // Parse a given expression String. Returns nil on failure, an
        // Expression otherwise.
        static func parse(_ exp: String) -> Expression? {
          guard exp.count > 0 else { return nil }
          if let number = Int(exp) {
            return .literal(number)
          } else {
            return .identifier(exp[exp.startIndex])
          }
        }

        // Evaluate this expression. The fetch closure is used to get the value
        // from a register (if needed).
        func eval(fetch: (Register) -> Int) -> Int {
          switch self {
            case .literal(let number):
              return number
            case .identifier(let reg):
              return fetch(reg)
          }
        }
      }

      // Parsing stuff.
      static let REG_REGEX = Regex("(set|sub|mul) ([a-z]) ([a-z]|-?[0-9]+)")
      static let JMP_REGEX = Regex("(jnz) ([a-z]|-?[0-9]+) ([a-z]|-?[0-9]+)")

      case set(reg: Register, exp: Expression)
      case sub(reg: Register, exp: Expression)
      case mul(reg: Register, exp: Expression)
      case jnz(cond: Expression, offset: Expression)

      // Parse a given instruction String. Returns nil on failure, a new
      // Instruction otherwise.
      static func parse(_ line: String) -> Instruction? {
        if let match = Instruction.REG_REGEX.firstMatch(in: line) {
          let reg = Register(match.captures[1]!)
          let exp = Expression.parse(match.captures[2]!)!
          switch match.captures[0]! {
            case "set": return .set(reg: reg, exp: exp)
            case "sub": return .sub(reg: reg, exp: exp)
            case "mul": return .mul(reg: reg, exp: exp)
            default: return nil
          }
        } else if let match = Instruction.JMP_REGEX.firstMatch(in: line) {
          let cond   = Expression.parse(match.captures[1]!)!
          let offset = Expression.parse(match.captures[2]!)!
          switch match.captures[0]! {
            case "jnz": return .jnz(cond: cond, offset: offset)
            default: return nil
          }
        } else { // parsing failed.
          return nil
        }
      }

      // Conform to CustomStringConvertible. Don't render the parameters, only
      // the instruction's mnemonic.
      var description: String {
        switch self {
          case .set(_, _): return "set"
          case .sub(_, _): return "set"
          case .mul(_, _): return "mul"
          case .jnz(_, _): return "jnz"
        }
      }
    }

    let instructions: [Instruction]

    // Parse a program, one instruction per line. Returns nil on parsing
    // failure.
    public convenience init?(_ asm: String) {
      let lines = asm.split(separator: "\n").map(String.init)
      self.init(lines)
    }

    // Parse a program, one instruction per element in the given lines. Returns
    // nil on failure to parse any of the line.
    public convenience init?(_ lines: [String]) {
      var instructions: [Instruction] = []
        for line in lines {
          guard let instruction = Instruction.parse(line) else { return nil }
          instructions.append(instruction)
        }
      self.init(instructions)
    }

    // Create a program given its list of instruction.
    init(_ instructions: [Instruction]) {
      self.instructions = instructions
    }
  }

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
}
