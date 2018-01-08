import DiskDefragmentation

let puzzle = readLine()! // Acquire puzzle input from stdin.
let disk = DiskDefragmentation(key: puzzle)
print("There are \(disk.used_square_count) squares are used across the grid,")
print("forming \(disk.region_count) regions.")
