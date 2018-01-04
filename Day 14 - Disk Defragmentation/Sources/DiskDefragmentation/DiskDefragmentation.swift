import KnotHash

// The disk's defragmentation job.
public class DiskDefragmentation {
  static let GRID_ROW_COUNT = 128 // grid size

  let rows: [KnotHash.Result]

  // Create a defragmenter given its hash key input.
  public init(key: String) {
    let range  = 0..<DiskDefragmentation.GRID_ROW_COUNT
    let inputs = range.map { "\(key)-\($0)" }
    self.rows  = inputs.map { KnotHash.hash($0) }
  }

  // Returns the count of used (i.e. non-free) squares.
  public var used_square_count: Int {
    return rows.reduce(0) { $0 + $1.popcnt }
  }
}

extension KnotHash.Result {
  // Hamming weight over the KnotHash.Result bytes.
  public var popcnt: Int {
    return bytes.reduce(0) { $0 + $1.nonzeroBitCount }
  }
}
