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
      return Layer(range: parts[0], depth: parts[1])
    }
    self.init(layers)
  }

  // Create a packet scanner from an array of layer.
  init(_ layers: [Layer]) {
    self.layers = layers
  }

  // Returns the trip severity when leaving immediately.
  public var trip_severity: Int {
    return layers.filter { $0.has_caught_me }.reduce(0) { $0 + $1.severity }
  }

  // Represents one layer of the firewall.
  class Layer {
    let range: Int
    let depth: Int

    // Create a new layer at a given range with the provided depth.
    init(range: Int, depth: Int) {
      self.range = range
      self.depth = depth
    }

    // Returns this layer's security scanner frequency.
    var frequency: Int {
      return 2 * (depth - 1)
    }

    // Returns true if this layer has caught our packet when leaving
    // immediately, false otherwise.
    var has_caught_me: Bool {
      return (frequency == 0 || range % frequency == 0)
    }

    // Returns this layer severity of getting caught by it.
    var severity: Int {
      return depth * range
    }
  }
}

// stolen from https://stackoverflow.com/a/41893447
extension String {
  var trimmed: String {
    return self.trimmingCharacters(in: .whitespaces)
  }
}
