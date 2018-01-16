import Regex

// Assembly code written on a tablet.
public class Duet {
  // A register name.
  typealias Register = Character

  // The tablet's assembly code, a program holding a list of instructions.
  public class Assembly {
    let instructions: [Instruction]

    // An instruction from the tablet.
    enum Instruction {
      // Either an integer or a register name.
      enum Expression {
        case literal(Int)
        case identifier(Register)

        // Parse a given expression String. Returns nil on failure, an
        // Expression otherwise.
        static func parse(_ expr: String) -> Expression? {
          guard expr.count > 0 else { return nil }
          if let number = Int(expr) {
            return .literal(number)
          } else {
            return .identifier(expr[expr.startIndex])
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
      static let SOUND_REGEX = Regex("(snd|rcv) ([a-z])")
      static let MOD_REGEX   = Regex("(set|add|mul|mod) ([a-z]) ([a-z]|-?[0-9]+)")
      static let CTRL_REGEX  = Regex("(jgz) ([a-z]|-?[0-9]+) ([a-z]|-?[0-9]+)")

      case snd(source: Register)
      case rcv(cond: Register)
      case set(reg: Register, expr: Expression)
      case add(reg: Register, expr: Expression)
      case mul(reg: Register, expr: Expression)
      case mod(reg: Register, expr: Expression)
      case jgz(cond: Expression, offset: Expression)

      // Parse a given instruction String. Returns nil on failure, a new
      // Instruction otherwise.
      static func parse(_ line: String) -> Instruction? {
        if let match = Instruction.SOUND_REGEX.firstMatch(in: line) {
          let reg = Register(match.captures[1]!)
          switch match.captures[0]! {
            case "snd": return .snd(source: reg)
            case "rcv": return .rcv(cond: reg)
            default: return nil
          }
        } else if let match = Instruction.MOD_REGEX.firstMatch(in: line) {
          let reg  = Register(match.captures[1]!)
          let expr = Expression.parse(match.captures[2]!)!
          switch match.captures[0]! {
            case "set": return .set(reg: reg, expr: expr)
            case "add": return .add(reg: reg, expr: expr)
            case "mul": return .mul(reg: reg, expr: expr)
            case "mod": return .mod(reg: reg, expr: expr)
            default: return nil
          }
        } else if let match = Instruction.CTRL_REGEX.firstMatch(in: line) {
          let cond   = Expression.parse(match.captures[1]!)!
          let offset = Expression.parse(match.captures[2]!)!
          switch match.captures[0]! {
            case "jgz": return .jgz(cond: cond, offset: offset)
            default: return nil
          }
        } else { // parsing failed.
          return nil
        }
      }

      // Execute this Instruction on the given processor.
      func execute(on cpu: Processor) {
        // syntaxic sugar to evaluate an Expression.
        func eval(_ expression: Expression) -> Int {
          return expression.eval(fetch: { cpu[$0] })
        }
        switch self {
          case .snd(let source):
            cpu.play(source: source)
          case .set(let reg, let expr):
            cpu[reg] = eval(expr)
          case .add(let reg, let expr):
            cpu[reg] = cpu[reg] + eval(expr)
          case .mul(let reg, let expr):
            cpu[reg] = cpu[reg] * eval(expr)
          case .mod(let reg, let expr):
            cpu[reg] = cpu[reg] % eval(expr)
          case .rcv(let cond):
            if cpu[cond] != 0 {
              cpu.recover()
            }
          case .jgz(let cond, let offset):
            if eval(cond) != 0 {
              cpu.jump(offset: eval(offset))
            }
        }
      }
    }

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

  // A Central Processor Unit able to evaluate the assembly code found on the
  // tablet.
  public class Processor {
    let rcv: (Int?) -> Bool              // callback when a sound is received.
    let default_value: Int               // default register value.
    var registers: [Register: Int] = [:] // the processor's registers.
    var sound: Int? = nil                // last played sound.
    var pc: Int = 0                      // program counter.

    // Create a new processor given its default value for its registers and a
    // receive callback. The receive callback must return true if the program
    // should continue the execution after the receive instruction, false
    // otherwise.
    public init(default_value: Int = 0, rcv: @escaping (Int?) -> Bool) {
      self.default_value = default_value
      self.rcv = rcv
    }

    // Execute the given program on this processor.
    public func execute(_ program: Assembly) {
      while pc >= 0 && pc < program.instructions.count {
        let instruction = program.instructions[pc]
        // Save the program counter to detect the instruction made a jump.
        let old_pc = pc
        instruction.execute(on: self)
        if pc == old_pc {
          // Here we did not perform jump or stopped execution, so we simply
          // advance the program counter.
          pc += 1
        }
      }
    }

    // Shortcut to get and set this processor registers.
    subscript(_ reg: Register) -> Int {
      get {
        return registers[reg] ?? default_value
      }
      set(newValue) {
        registers[reg] = newValue
      }
    }

    // Play the sound with a frequency taken from the given register.
    func play(source: Register) {
      sound = self[source]
    }

    // Recover the last played frequency.
    func recover() {
      // NOTE: if the receive callback returns false, we should stop the
      // program's execution.
      if !rcv(sound) {
        pc = -1 // terminate the execution
      }
    }

    // Perform a jump to the instruction at the given offset with respect to
    // the current one.
    func jump(offset: Int) {
      pc += offset
    }
  }
}
