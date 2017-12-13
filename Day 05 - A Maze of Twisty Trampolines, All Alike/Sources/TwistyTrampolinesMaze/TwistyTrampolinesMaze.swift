public class TwistyTrampolinesMaze {
  let trampoline: [Int]

  public init(_ trampoline: [Int]) {
    self.trampoline = trampoline
  }

  // NOTE: part one
  public var exit: Int {
    var (pc, step, trampoline) = (0, 0, self.trampoline)
    while pc >= 0 && pc < trampoline.count {
      step += 1
      trampoline[pc] += 1
      pc += trampoline[pc] - 1
    }
    return step
  }
}
