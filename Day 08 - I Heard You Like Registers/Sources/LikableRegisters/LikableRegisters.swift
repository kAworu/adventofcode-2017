import Regex

// Serie of unusual register instructions.
public class LikableRegisters {
  let instructions: [Instruction]

  // Create a new serie of instructions, one instruction per line. Returns nil
  // if any instruction was not parsed successfully.
  convenience init?(_ list: String) {
    let lines = list.split(separator: "\n").map(String.init)
    self.init(lines)
  }

  // Parse a new serie of instructions. Returns nil if any instruction was not
  // parsed successfully.
  public init?(_ lines: [String]) {
    var instructions: [Instruction] = []
    for line in lines {
      guard let instruction = Instruction(line) else { return nil }
      instructions.append(instruction)
    }
    self.instructions = instructions
  }

  // see Processor.execute
  // XXX: maybe we should have a typealias for this registerish tuple.
  public func compute(on cpu: Processor) -> (key: String, value: Int)? {
    return cpu.execute(instructions)
  }

  // Represents a CPU and its registers.
  public class Processor {
    let default_value: Int
    var registers: [String: Int] = [:]

    // Create a new processor having the given default value for its registers.
    public init(default_value: Int = 0) {
      self.default_value = default_value
    }

    // Returns the register that held the highest value through the execution of
    // the given instructions. If no store was performed, nil is returned.
    func execute(_ instructions: [Instruction]) -> (key: String, value: Int)? {
      var all_time_max: (key: String, value: Int)? = nil
      for instruction in instructions {
        instruction.execute(
          fetch: { registers[$0, default: default_value] },
          store: { reg, val in
            registers[reg] = val
            if all_time_max == nil || all_time_max!.value < val {
              all_time_max = (key: reg, value: val)
            }
          }
        )
      }
      return all_time_max
    }

    // Returns the register holding the current max value.
    public var max: (key: String, value: Int)? {
      return self.registers.max(by: { $0.value < $1.value })
    }
  }

  // Represents an unusual register instruction.
  class Instruction {
    static let REGEX = Regex("([a-z]+) (inc|dec) (-?[0-9]+) if ([a-z]+) (<|<=|>|>=|==|!=) (-?[0-9]+)")

    // this instruction "move" and "comparison" expressions.
    let mov, cmp: (reg: String, op: Operator, num: Int)

    // Parse a new instruction from the given string. Returns nil on failure.
    init?(_ s: String) {
      guard let match = Instruction.REGEX.firstMatch(in: s) else { return nil }
      self.mov = (
        reg: match.captures[0]!,
        op: Operator(rawValue: match.captures[1]!)!,
        num: Int(match.captures[2]!)!)
      self.cmp = (
        reg: match.captures[3]!,
        op: Operator(rawValue: match.captures[4]!)!,
        num: Int(match.captures[5]!)!)
    }

    // execute this instruction. The given fetch and store function are used to
    // read from (respectively write to) the registers.
    func execute(fetch: (String) -> Int, store: (String, Int) -> Void) {
      if cmp.op.eval(fetch(cmp.reg), cmp.num) == 1 {
        let old = fetch(mov.reg)
        let new = mov.op.eval(old, mov.num)
        store(mov.reg, new)
      }
    }
  }

  // Instruction expression operators.
  enum Operator: String {
    // math op
    case add = "inc"
    case sub = "dec"
    // rel op
    case lt  = "<"
    case lte = "<="
    case gt  = ">"
    case gte = ">="
    case eq  = "=="
    case neq = "!="

    // simplicity beats purity: rel op returns 1 when true, 0 otherwise.
    func eval(_ lhs: Int, _ rhs: Int) -> Int {
      switch self {
        case .add: return lhs + rhs
        case .sub: return lhs - rhs
        case .lt:  return lhs <  rhs ? 1 : 0
        case .lte: return lhs <= rhs ? 1 : 0
        case .gt:  return lhs >  rhs ? 1 : 0
        case .gte: return lhs >= rhs ? 1 : 0
        case .eq:  return lhs == rhs ? 1 : 0
        case .neq: return lhs != rhs ? 1 : 0
      }
    }
  }
}
