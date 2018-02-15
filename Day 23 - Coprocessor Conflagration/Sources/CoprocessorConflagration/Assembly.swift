import Regex

extension CoprocessorConflagration {
  // The tablet's assembly code variante run by the coprocessor.
  public struct Assembly {
    let instructions: [Instruction]

    // Parse a program, one instruction per line. Returns nil on parsing
    // failure.
    public init?(_ asm: String) {
      let lines = asm.split(separator: "\n").map(String.init)
      self.init(lines)
    }

    // Parse a program, one instruction per element in the given lines. Returns
    // nil on failure to parse any of the line.
    public init?(_ lines: [String]) {
      var instructions: [Instruction] = []
        for line in lines {
          guard let instruction = Instruction.parse(line) else { return nil }
          instructions.append(instruction)
        }
      self.init(instructions)
    }

    // Create a program given its list of instruction.
    private init(_ instructions: [Instruction]) {
      self.instructions = instructions
    }

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
      private static let RE = (
        reg: Regex("(set|sub|mul) ([a-z]) ([a-z]|-?[0-9]+)"),
        jmp: Regex("(jnz) ([a-z]|-?[0-9]+) ([a-z]|-?[0-9]+)")
      )

      case set(reg: Register, exp: Expression)
      case sub(reg: Register, exp: Expression)
      case mul(reg: Register, exp: Expression)
      case jnz(cond: Expression, offset: Expression)

      // Parse a given instruction String. Returns nil on failure, a new
      // Instruction otherwise.
      static func parse(_ line: String) -> Instruction? {
        if let match = Instruction.RE.reg.firstMatch(in: line) {
          let reg = Register(match.captures[1]!)
          let exp = Expression.parse(match.captures[2]!)!
          switch match.captures[0]! {
            case "set": return .set(reg: reg, exp: exp)
            case "sub": return .sub(reg: reg, exp: exp)
            case "mul": return .mul(reg: reg, exp: exp)
            default: return nil
          }
        } else if let match = Instruction.RE.jmp.firstMatch(in: line) {
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
  }
}
