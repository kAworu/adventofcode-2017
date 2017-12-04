public class SpiralMemory {
  var target: Int

  public init(_ target: Int) {
    self.target = target
  }

 // each spirale "circle" ends with the square of an odd number. We'll call
 // this number the circle's "level", and it follow that the circle level n
 // contains the numbers between (n - 2) ** 2 + 1 and n ** 2.
  public var snake_distance: Int {
    if target == 1 {
      return 0
    }
    // first let's find out on which "circle level" is the target. The last
    // number of each circle is a square:
    // - the first is 9 ->   "level 3" (3 * 3 =  9),
    // - the second is 25 -> "level 5" (5 * 5 = 25),
    // - the n is level (n * 2) ** 2.
    let sqrt = Double(target).squareRoot()
    let n = Int(sqrt.rounded(.up))
    let level = n + (n % 2 == 0 ? 1 : 0)
    // We found the level, i.e. `target' is between the previous level's bottom
    // right square number ((level - 2) ** 2 + 1) and this level's bottom right
    // square (level ** 2).

    // At that point we know that we need at least (level / 2) steps to move to
    // the right circle level. We'll end up in the middle of one of the side of
    // the circle. Now we may need to "drift" from the "middle side number".
    var (min, max) = (level * level - level + 1, level * level)
    // min and max are the bottom left respectively bottom right numbers of our
    // circle level. Let's switch side clockwise until we find the border where
    // `target' is.
    while target < min {
      (max, min) = (min, min - level + 1)
    }
    let mid = min + (max - min) / 2 // NOTE: (max - min) is even.
    // the drift is the absolute diff between the number at the center of the
    // side and our `target'.
    let drift = Int((target - mid).magnitude)

    // move to the side directly and then drift.
    return level / 2 + drift
  }
}
