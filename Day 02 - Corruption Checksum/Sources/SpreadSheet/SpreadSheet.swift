// A corrupted Spreadsheet.
public class SpreadSheet {
  let rows: [Row]

  // Create a new Spreadsheet, one row per line.
  public init(_ lines: String) {
    rows = lines.split(separator: "\n").map { Row(String($0)) }
  }

  // Returns the sum of the Spreadsheet's rows checksum.
  public var checksum: Int {
    return rows.reduce(0) { $0 + $1.checksum }
  }

  // Returns the sum of the Spreadsheet's rows even division.
  public var division: Int {
    return rows.reduce(0) { $0 + $1.division }
  }

  // Represent one row of a Spreadsheet.
  class Row {
    let numbers: [Int]

    // Create a new row, numbers separated by spaces and/or tabs.
    init(_ line: String) {
      // NOTE: handle spaces as separator for the tests.
     numbers = line.split { $0 == "\t" || $0 == " "}.map { Int($0)! }
    }

    // Returns the difference between this row's maximum and minimum number.
    // Returns -1 when this row is empty.
    var checksum: Int {
      guard let min = numbers.min() else { return -1 }
      guard let max = numbers.max() else { return -1 }
      return (max - min)
    }

    // Find a and b such as a divided by b is a whole number and return the
    // division's result, returns zero otherwise.
    var division: Int {
      for (i, x) in numbers.enumerated() {
          for y in numbers[(i + 1)..<numbers.count] {
            let (min, max) = (x > y ? (y, x) : (x, y))
            if max % min == 0 {
              return max / min
            }
        }
      }
      return 0
    }
  }
}
