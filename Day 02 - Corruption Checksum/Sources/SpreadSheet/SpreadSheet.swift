// A corrupted Spreadsheet.
public class SpreadSheet {
  let rows: [Row]

  public init(_ lines: String) {
    rows = lines.split(separator: "\n").map { Row(String($0)) }
  }

  // NOTE: part one
  public var checksum: Int {
    return rows.map { $0.checksum }.reduce(0, +)
  }

  // NOTE: part two
  public var division: Int {
    return rows.map { $0.division }.reduce(0, +)
  }
}


// Represent one row of a SpreadSheet.
class Row {
  let digits: [Int]

  init(_ line: String) {
    // NOTE: handle spaces as separator for the tests.
    digits = line.split { $0 == "\t" || $0 == " "}.map { Int($0)! }
  }

  var checksum: Int {
    guard let first = digits.first else {
      return 0
    }
    let mm = digits.reduce((min: first, max: first)) { acc, x in
      if x > acc.max {
        return (min: acc.min, max: x)
      } else if x < acc.min {
        return (min: x, max: acc.max)
      } else {
        return acc
      }
    }
    return (mm.max - mm.min)
  }

  var division: Int {
    for (i, x) in digits.enumerated() {
        for y in digits[(i + 1)..<digits.count] {
          let (min, max) = (x > y ? (y, x) : (x, y))
          if max % min == 0 {
            return max / min
          }
      }
    }
    return 0
  }
}
