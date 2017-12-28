// Captcha to be solved so that we can open the "Restricted Area" door.
public class InverseCaptcha {
  // the captcha's digit, in order.
  let digits: [Int]

  // Create a new captcha solver.
  public init(_ captcha: String) {
    digits = captcha.map { Int(String($0))! }
  }

  // Returns the sum of digit having a match with the immediate next one.
  public var neighbour_sum: Int {
    return solve { i in (i + 1) % digits.count }
  }

  // Returns the sum of digit having a match with the halfway around digit.
  public var halfway_around_sum: Int {
    return solve { i in (i + digits.count / 2) % digits.count }
  }

  // Returns the sum of all digits equals to their "next" digit. The given
  // `next` function must provide the "next" digit index given the current
  // digit index.
  internal func solve(next: (Int) -> Int) -> Int {
    return digits.indices.reduce(0) { acc, i in
      let (current, match) = (digits[i], digits[next(i)])
      return acc + (current == match ? current : 0)
    }
  }
}
