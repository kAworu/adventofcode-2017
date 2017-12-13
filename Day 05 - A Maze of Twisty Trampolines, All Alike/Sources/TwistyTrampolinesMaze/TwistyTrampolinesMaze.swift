public class TwistyTrampolinesMaze {
  let instructions: [Int]

  public init(_ instructions: [Int]) {
    self.instructions = instructions
  }

  // NOTE: part one
  public var strange_jumps_exit: Int {
    return step_count_to_exit { $0 + 1 }
  }

  // NOTE: part two
  public var stranger_jumps_exit: Int {
    return step_count_to_exit { $0 + ($0 >= 3 ? -1 : +1) }
  }

  // follow the maze instructions using the provided `update' function to
  // compute the new instruction value under `pc' after each jump. Returns the
  // number of step performed before we reached an exit.
  internal func step_count_to_exit(_ update: (Int) -> Int) -> Int {
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
