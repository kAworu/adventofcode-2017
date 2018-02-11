import Regex

// Assembly code written on a tablet.
public class Duet {
  // Syntaxic sugar for register names.
  typealias Register = Character

  // The tablet's assembly code, a program holding a list of instructions.
  public class Assembly {
    // The instruction set revision.
    // - v1 uses .play and .recover for snd respectively rcv,
    // - v2 uses .send and .receive for snd respectively rcv.
    public enum Revision { case v1, v2 }

    // An instruction from the tablet.
    enum Instruction {
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
      static let SND_REGEX = Regex("snd ([a-z]|-?[0-9]+)")
      static let RCV_REGEX = Regex("rcv ([a-z])")
      static let REG_REGEX = Regex("(set|add|mul|mod) ([a-z]) ([a-z]|-?[0-9]+)")
      static let JMP_REGEX = Regex("(jgz) ([a-z]|-?[0-9]+) ([a-z]|-?[0-9]+)")

      // v1 & v2 instructions
      case set(reg: Register, exp: Expression)
      case add(reg: Register, exp: Expression)
      case mul(reg: Register, exp: Expression)
      case mod(reg: Register, exp: Expression)
      case jgz(cond: Expression, offset: Expression)
      // v1 instructions
      case play(src: Expression)
      case recover(cond: Register)
      // v2 instructions
      case send(src: Expression)
      case receive(dest: Register)

      // Parse a given instruction String. Returns nil on failure, a new
      // Instruction otherwise. Different instructions are generated for both
      // `snd` and `rcv` depending on the requested revision of the instruction
      // set.
      static func parse(_ line: String, revision: Revision) -> Instruction? {
        if let match = Instruction.SND_REGEX.firstMatch(in: line) {
          let src = Expression.parse(match.captures[0]!)!
          switch (revision) {
            case .v1: return .play(src: src)
            case .v2: return .send(src: src)
          }
        } else if let match = Instruction.RCV_REGEX.firstMatch(in: line) {
          let reg = Register(match.captures[0]!)
          switch (revision) {
            case .v1: return .recover(cond: reg)
            case .v2: return .receive(dest: reg)
          }
        } else if let match = Instruction.REG_REGEX.firstMatch(in: line) {
          let reg = Register(match.captures[1]!)
          let exp = Expression.parse(match.captures[2]!)!
          switch match.captures[0]! {
            case "set": return .set(reg: reg, exp: exp)
            case "add": return .add(reg: reg, exp: exp)
            case "mul": return .mul(reg: reg, exp: exp)
            case "mod": return .mod(reg: reg, exp: exp)
            default: return nil
          }
        } else if let match = Instruction.JMP_REGEX.firstMatch(in: line) {
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
    }

    let instructions: [Instruction]

    // Parse a program, one instruction per line. Returns nil on parsing
    // failure.
    public convenience init?(_ revision: Revision, _ asm: String) {
      let lines = asm.split(separator: "\n").map(String.init)
      self.init(revision, lines)
    }

    // Parse a program, one instruction per element in the given lines. Returns
    // nil on failure to parse any of the line.
    public convenience init?(_ revision: Revision, _ lines: [String]) {
      var instructions: [Instruction] = []
        for line in lines {
          if let instruction = Instruction.parse(line, revision: revision) {
            instructions.append(instruction)
          } else {
            return nil
          }
        }
      self.init(instructions)
    }

    // Create a program given its list of instruction.
    init(_ instructions: [Instruction]) {
      self.instructions = instructions
    }
  }

  // A Central Processor Unit able to execute the assembly code found on the
  // tablet.
  public class Processor {
    // A special register initially holding the processor's id.
    static let ID_REGISTER: Register = "p"

    // Type of event emmited by the CPU.
    public enum Event { case recover, send }

    // Function type used as event callback by the processor.
    public typealias Callback = (Int?) -> Execution

    // The CPU execution state.
    public enum Execution { case proceed, wait, stop }

    let id: Int                            // this processor's ID
    let program: Assembly                  // the program to execute.
    var registers: [Register: Int] = [:]   // the processor's registers.
    let default_value: Int = 0             // default register value.
    var state: Execution = .proceed        // execution flow state.
    var pc: Int = 0                        // program counter.
    var listeners: [Event: Callback] = [:] // registered callback per event.
    var sound: Int? = nil                  // The last played sound.
    var messages: [Int] = []               // FIFO message queue for this CPU.

    // Create a new processor given its id. The Processor.ID_REGISTER will be
    // initially set to the processor id.
    public init(id: Int = 0, program: Assembly) {
      self.id = id
      self.program = program
      self[Processor.ID_REGISTER] = Int(id)
    }

    // Register the given callback function to be called when the provided
    // event arise. Returns the callback previously setup for the event if any.
    @discardableResult
    public func on(_ event: Event, callback: @escaping Callback) -> Callback? {
      let old = listeners[event]
      listeners[event] = callback
      return old
    }

    // Execute the program on this processor.
    public func run() {
      while let current = instruction {
        execute(current)
        if !advance() {
          // Here we did not made progress by executing the current
          // instruction, i.e. we're waiting. Explicitely break the loop since
          // we still do have a next instruction (the same as the current).
          break
        }
      }
    }

    // Send the given message to this CPU.
    public func notify(msg: Int) {
      messages.append(msg)
    }

    // True if this CPU is waiting to receive a message, false otherwise.
    public var is_waiting: Bool {
      return state == .wait && messages.count == 0
    }

    // True if this CPU is stopped, false otherwise.
    public var is_stopped: Bool {
      return state == .stop
    }

    // Execute a given instruction on this processor.
    func execute(_ instruction: Assembly.Instruction) {
      // syntaxic sugar to evaluate an Expression.
      func eval(_ expression: Assembly.Instruction.Expression) -> Int {
        return expression.eval(fetch: { self[$0] })
      }
      switch instruction {
        // v1 & v2 instructions
        case .set(let reg, let exp):
          self[reg] = eval(exp)
        case .add(let reg, let exp):
          self[reg] = self[reg] + eval(exp)
        case .mul(let reg, let exp):
          self[reg] = self[reg] * eval(exp)
        case .mod(let reg, let exp):
          self[reg] = self[reg] % eval(exp)
        case .jgz(let cond, let offset):
          if eval(cond) > 0 {
            // NOTE: minus one because the pc will be advanced by one after the jump
            // instruction execution.
            pc += Int(eval(offset) - 1)
          }
        // v1 instructions
        case .play(let src):
          sound = eval(src)
        case .recover(let cond):
          if self[cond] != 0 {
            guard let on_recover = listeners[.recover] else { return }
            state = on_recover(sound)
          }
        // v2 instructions are implemented with the CPU messages queue: the
        // send instruction only call the listener (if any) and the receive
        // instruction consume the first element from the queue (if any).
        case .send(let src):
          guard let on_send = listeners[.send] else { return }
          state = on_send(eval(src))
        case .receive(let dest):
          if let value = messages.first {
            // We got a message, consume it and set the destination register
            // with the message's value.
            messages.removeFirst()
            self[dest] = value
            // When we retry a .receive instruction we are in .wait state. Now
            // that we got our message let's .proceed again (NOTE: we could
            // also just be .proceed'ing here)
            state = .proceed
          } else {
            // We don't have a message to consume for our .receive instruction.
            // Let's .wait and retry this instruction on the next run.
            state = .wait
          }
      }
    }

    // Advance the program counter if we are not waiting nor stopped. Then,
    // stop if we've reached the end of the program. Returns true if the
    // program counter has changed, false otherwise.
    func advance() -> Bool {
      guard state == .proceed else { return false }
      pc += 1
      // Check against zero just to be sure, (e.g. bad jump).
      if !(0..<program.instructions.count).contains(pc) {
        state = .stop
      }
      return true
    }

    // The instruction to be executed by the CPU, if any.
    var instruction: Assembly.Instruction? {
      guard state != .stop else { return nil }
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

  // Run both given processor until both are stop or a deadlock happen.  Before
  // they are run, the processors are setup to communicate with each other:
  // that is when p0 (or p1) send a message, p1 (respectively p0) is notified.
  // If a callback was already setup for the .send event it will still be
  // called.
  public static func run_in_duet(_ p0: Processor, and p1: Processor) {
    // Install a dummy callback for the .send event just so that we can
    // retrieve the current one (if any).
    let noop: Processor.Callback = { _ in .proceed }
    let maybe_p0_on_send = p0.on(.send, callback: noop)
    let maybe_p1_on_send = p1.on(.send, callback: noop)
    // Bind to the .send event to notifiy the other processor, "wrapping" the
    // callback previously installed. NOTE: a retain cycle is created here.
    p0.on(.send) {
      p1.notify(msg: $0!)
      guard let p0_on_send = maybe_p0_on_send else { return .proceed }
      return p0_on_send($0)
    }
    p1.on(.send) {
      p0.notify(msg: $0!)
      guard let p1_on_send = maybe_p1_on_send else { return .proceed }
      return p1_on_send($0)
    }
    // Run both processor until they stop or we're in a deadlock situation
    // (i.e. both CPU are waiting)
    let both_stopped = { p0.is_stopped && p1.is_stopped }
    let deadlock     = { p0.is_waiting && p1.is_waiting }
    while !both_stopped() && !deadlock() {
      p0.run()
      p1.run()
    }
    // Restore the old .send callbacks (if any), breaking the retain cycle.
    p0.on(.send, callback: maybe_p0_on_send ?? noop)
    p1.on(.send, callback: maybe_p1_on_send ?? noop)
  }
}
