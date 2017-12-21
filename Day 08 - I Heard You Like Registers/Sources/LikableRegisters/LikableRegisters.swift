import Regex

public class LikableRegisters {
  let instructions: [Instruction]

  convenience init?(_ list: String) {
    let lines = list.split(separator: "\n").map(String.init)
    self.init(lines)
  }

  public init?(_ lines: [String]) {
    var instructions: [Instruction] = []
    for line in lines {
      guard let instruction = Instruction(line) else {
        return nil
      }
      instructions.append(instruction)
    }
    self.instructions = instructions
  }

  public func compute(on cpu: Processor) {
    for instruction in instructions {
      cpu.execute(instruction)
    }
  }
}

public class Processor {
  let default_value: Int
  var registers: [String: Int] = [:]

  public init(default_value: Int = 0) {
    self.default_value = default_value
  }

  func execute(_ instruction: Instruction) {
    instruction.execute(
      fetch: { registers[$0] ?? default_value },
      store: { registers[$0] = $1 }
    )
  }

  public var max: (key: String, value: Int)? {
    return self.registers.max(by: { $0.value < $1.value })
  }
}

class Instruction {
  static let REGEX = Regex("([a-z]+) (inc|dec) (-?[0-9]+) if ([a-z]+) (<|<=|>|>=|==|!=) (-?[0-9]+)")

  let cmp, mov: (reg: String, op: Operator, num: Int)

  init?(_ s: String) {
    guard let match = Instruction.REGEX.firstMatch(in: s) else {
      return nil
    }
    self.mov = (
      reg: match.captures[0]!,
      op: Operator(rawValue: match.captures[1]!)!,
      num: Int(match.captures[2]!)!)
    self.cmp = (
      reg: match.captures[3]!,
      op: Operator(rawValue: match.captures[4]!)!,
      num: Int(match.captures[5]!)!)
  }

  func execute(fetch: (String) -> Int, store: (String, Int) -> Void) {
    if cmp.op.eval(fetch(cmp.reg), cmp.num) == 1 {
      let old = fetch(mov.reg)
      let new = mov.op.eval(old, mov.num)
      store(mov.reg, new)
    }
  }
}

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
