public class MemoryReallocation {
  let banks: [Bank]

  public init(_ blocks_per_bank: [Int]) {
    self.banks = blocks_per_bank.enumerated().map { (index, blocks) in
      return Bank(id: index, blocks)
    }
  }

  public var redistribution_cycles_count: Int {
    var seen: Set<String> = []
    var banks = self.banks
    var desc  = banks.description
    var cycle = 0
    while !seen.contains(desc) {
      seen.insert(desc)
      let giver = banks.max()!
      // update the banks by redistributing giver's blocks
      let (start, stop) = (giver.id + 1, giver.id + giver.blocks)
      giver.blocks = 0
      for i in start...stop {
        banks[i % banks.count].blocks += 1
      }
      cycle += 1
      desc = banks.description
    }
    return cycle
  }
}

class Bank {
  let id: Int
  var blocks: Int

  init (id: Int, _ blocks: Int) {
    self.id     = id
    self.blocks = blocks
  }
}

// so that we can compare Bank and use [Bank].max()
extension Bank: Comparable {
  static func <(lhs: Bank, rhs: Bank) -> Bool {
    if lhs.blocks == rhs.blocks {
      // NOTE: tie won by the lowest-numbered memory bank
      return lhs.id > rhs.id
    } else {
      return lhs.blocks < rhs.blocks
    }
  }

  static func ==(lhs: Bank, rhs: Bank) -> Bool {
    return lhs.id == rhs.id && lhs.blocks == rhs.blocks
  }
}

// Bank serialization used to compare [Bank] state.
extension Bank: CustomStringConvertible {
  var description: String {
    return "\(self.id):\(self.blocks)"
  }
}
