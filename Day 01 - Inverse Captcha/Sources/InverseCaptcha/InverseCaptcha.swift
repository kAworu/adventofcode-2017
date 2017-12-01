public class InverseCaptcha {
  var digits: Array<Int>

  public init(_ captcha: String) {
    self.digits = captcha.map { Int(String($0))! }
  }

  // NOTE: part one
  public func solve_next() -> Int {
    return self.solve { $0 + 1 }
  }

  // NOTE: part two
  public func solve_halfway_around() -> Int {
    return self.solve { $0 + self.digits.count / 2 }
  }

  internal func solve(next: (Int) -> Int) -> Int {
    return self.digits.indices.reduce(0, { acc, i in
      let current = self.digits[i]
      let match   = self.digits[next(i) % self.digits.count]
      return acc + (current == match ? current : 0)
    })
  }
}
