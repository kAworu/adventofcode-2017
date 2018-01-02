// A maze solver to help the CPU to find the exit.
public class TwistyTrampolinesMaze {
  let instructions: [Int]

  // Create a new solver from a list of jump offsets instructions.
  public init(_ instructions: [Int]) {
    self.instructions = instructions
  }

  // After each jump, the offset of that instruction increases by one.
  public var strange_jumps_exit: Int {
    return step_count_to_exit { $0 + 1 }
  }

  // After each jump, the offset of that instruction increase (or decrease) by
  // one if it was lesser than three (respectively three or more).
  public var stranger_jumps_exit: Int {
    return step_count_to_exit { $0 + ($0 >= 3 ? -1 : +1) }
  }

  // follow the maze instructions using the provided `update' function to
  // compute the new instruction value under `pc' after each jump. Returns the
  // number of step performed before we reached an exit.
  func step_count_to_exit(_ update: (Int) -> Int) -> Int {
    var (pc, nstep, instructions) = (0, 0, self.instructions)
    while pc >= 0 && pc < instructions.count {
      let instruction = instructions[pc]
      instructions[pc] = update(instruction)
      pc += instruction
      nstep += 1
    }
    return nstep
  }
}
