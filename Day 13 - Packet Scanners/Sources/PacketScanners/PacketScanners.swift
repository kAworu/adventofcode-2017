import Foundation

// The big firewall we need to cross.
public class PacketScanners {
  let layers: [Layer]

  // Create a packet scanner, given a layer per line.
  public convenience init(_ list: String) {
    let lines = list.split(separator: "\n").map(String.init)
    self.init(lines)
  }

  // Create a packet scanner from an array of layer description.
  public convenience init(_ lines: [String]) {
    let layers: [Layer] = lines.map { line in
      let parts = line.split(separator: ":").map { Int(String($0).trimmed)! }
      return Layer(depth: parts[0], range: parts[1])
    }
    self.init(layers)
  }

  // Create a packet scanner from an array of layer.
  init(_ layers: [Layer]) {
    self.layers = layers
  }

  // Returns the minimum delay (in picoseconds) for which the packet is not
  // caught by any layer.
  public var safe_trip_delay: Int {
    // Check small frequency layers first, speed up by ~10%
    let layers = self.layers.sorted(by: { $0.frequency < $1.frequency })
    // Start at one since we always get caught by the layer at depth=0 when
    // leaving immediately.
    var delay = 1
    while layers.contains(where: { $0.catching(delay) }) {
      delay += 1
    }
    return delay
  }

  // Returns the trip severity when leaving at the given delay
  // (a delay of zero means leaving immediately).
  public func trip_severity(delay: Int) -> Int {
    return layers.filter { $0.catching(delay) }.reduce(0) { $0 + $1.severity }
  }

  // Represents one layer of the firewall.
  class Layer {
    let depth, range: Int

    // Create a new layer at a given depth with the provided range.
    init(depth: Int, range: Int) {
      self.depth = depth
      self.range = range
    }

    // Returns this layer's security scanner frequency.
    var frequency: Int {
      return 2 * (range - 1)
    }

    // Returns true if this layer has caught our packet when leaving at the
    // given delay, false otherwise.
    func catching(_ delay: Int) -> Bool {
      return (frequency == 0 || (depth + delay) % frequency == 0)
    }

    // Returns this layer severity of getting caught by it.
    var severity: Int {
      return range * depth
    }
  }
}

// stolen from https://stackoverflow.com/a/41893447
extension String {
  var trimmed: String {
    return self.trimmingCharacters(in: .whitespaces)
  }
}
