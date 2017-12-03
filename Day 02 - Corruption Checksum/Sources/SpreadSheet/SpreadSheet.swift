// A corrupted Spreadsheet.
public class SpreadSheet {
  var rows: Array<Row>

  public init(_ lines: String) {
    rows = lines.split { $0 == "\n" }.map { Row(String($0)) }
  }

  public var checksum: Int {
    return rows.reduce(0, { acc, row in acc + row.checksum })
  }

  public var division: Int {
    return rows.reduce(0, { acc, row in acc + row.division })
  }
}


// Represent one row of a SpreadSheet.
class Row {
  var digits: Array<Int>

  init(_ line: String) {
    // NOTE: handle spaces as separator for the tests.
    digits = line.split { $0 == "\t" || $0 == " "}.map { Int($0)! }
  }

  var checksum: Int {
    guard let first = digits.first else {
      return 0
    }
    let mm = digits.reduce((min: first, max: first), { acc, x in
      if x > acc.max {
        return (min: acc.min, max: x)
      } else if x < acc.min {
        return (min: x, max: acc.max)
      } else {
        return acc
      }
    })
    return (mm.max - mm.min)
  }

  var division: Int {
    for (i, e) in digits.enumerated() {
        for f in digits[(i + 1)..<digits.count] {
          let (min, max) = (e > f ? (f, e) : (e, f))
          if max % min == 0 {
            return max / min
          }
      }
    }
    return 0
  }
}
