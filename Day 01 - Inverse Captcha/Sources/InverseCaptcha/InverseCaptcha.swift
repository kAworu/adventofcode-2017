public class InverseCaptcha {
  let digits: [Int]

  public init(_ captcha: String) {
    digits = captcha.map { Int(String($0))! }
  }

  // NOTE: part one
  public func next_solution() -> Int {
    return solve { $0 + 1 }
  }

  // NOTE: part two
  public func halfway_around_solution() -> Int {
    return solve { $0 + digits.count / 2 }
  }

  internal func solve(next: (Int) -> Int) -> Int {
    return digits.indices.reduce(0, { acc, i in
      let current = digits[i]
      let match   = digits[next(i) % digits.count]
      return acc + (current == match ? current : 0)
    })
  }
}
