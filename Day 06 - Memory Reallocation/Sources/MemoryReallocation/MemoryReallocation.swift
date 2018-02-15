// Our blocks-in-banks memory debugger.
public class MemoryReallocation {
  let banks: [Bank]

  // Create a new debugger given the blocks count per bank.
  public init(_ blocks_per_bank: [Int]) {
    self.banks = blocks_per_bank.enumerated().map { (index, blocks) in
      Bank(id: index, blocks: blocks)
    }
  }

  // Perform a reallocation cycle until a blocks-in-banks configuration
  // produced has been seen before. Returns a tuple containing
  // (the cycle count before the loop occur, the cycle count inside the loop).
  public func realloc() -> (before_looping: Int, loop: Int) {
    // banks state description to cycle number dictionary
    var seen: [String: Int] = [:]
    var banks = self.banks
    var desc  = "\(banks)"
    var cycle = 0
    while seen[desc] == nil {
      seen[desc] = cycle
      let giver = banks.max()!
      // update the banks by redistributing giver's blocks
      let (start, stop) = (giver.id + 1, giver.id + giver.blocks)
      giver.blocks = 0
      for i in start...stop {
        banks[i % banks.count].blocks += 1
      }
      desc = "\(banks)"
      cycle += 1
    }
    return (before_looping: cycle, loop: cycle - seen[desc]!)
  }

  // Represents a memory bank.
  class Bank: Comparable, CustomStringConvertible {
    // Returns true if lhs is lesser than rhs, false otherwise.
    static func < (lhs: Bank, rhs: Bank) -> Bool {
      if lhs.blocks == rhs.blocks {
        // NOTE: tie won by the lowest-numbered memory bank
        return lhs.id > rhs.id
      } else {
        return lhs.blocks < rhs.blocks
      }
    }

    // Returns true if lhs and rhs are equals, false otherwise.
    static func == (lhs: Bank, rhs: Bank) -> Bool {
      return lhs.id == rhs.id && lhs.blocks == rhs.blocks
    }

    let id: Int
    var blocks: Int

    // Create a bank given its id and block count.
    init(id: Int, blocks: Int) {
      self.id = id
      self.blocks = blocks
    }

    // Returns a String representation of this bank. Used to compare [Bank]
    // state.
    var description: String {
      return "\(self.id):\(self.blocks)"
    }
  }
}
