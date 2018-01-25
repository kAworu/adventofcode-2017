import SpreadSheet

// Acquire puzzle input from stdin.
func get_puzzle() -> String {
  var input = ""
  while let line = readLine(strippingNewline: false) {
    input += line
  }
  return input
}

let puzzle = get_puzzle()
let spreadsheet = SpreadSheet(puzzle)
print("The spreadsheet's checksum is \(spreadsheet.checksum()),")
print("and its evenly division is \(spreadsheet.division()).")
