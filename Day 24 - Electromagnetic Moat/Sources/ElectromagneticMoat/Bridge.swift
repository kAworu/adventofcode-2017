extension ElectromagneticMoat {
  // Represents a bridge of components.
  public struct Bridge: CustomStringConvertible {
    public static let pit = Bridge(components: [], port: 0, strength: 0)

    // The components forming this bridge (in order).
    let components: [Component]
    // The open port at the end of the bridge.
    let port: Component.Port
    // The bridge's strength
    public let strength: Int

    // Create a bridge by extending this one with the given component. Returns
    // nil if the provided component has no port matching the open port of this
    // bridge.
    func extended(with tail: Component) -> Bridge? {
      // NOTE: the new bridge components and strength are the same regardless
      // of the matching port, but they are built only if there is a match so
      // that failing to extend (i.e. returning nil) is cheap.
      if tail.ports.0 == port {
        let components = self.components + [tail]
        let port = tail.ports.1
        let strength = self.strength + tail.ports.0 + tail.ports.1
        return Bridge(components: components, port: port, strength: strength)
      } else if tail.ports.1 == port {
        let components = self.components + [tail]
        let port = tail.ports.0
        let strength = self.strength + tail.ports.0 + tail.ports.1
        return Bridge(components: components, port: port, strength: strength)
      } else {
        return nil
      }
    }

    // Returns true if this bridge is stronger than the given other one, false
    // otherwise.
    func is_stronger(than other: Bridge) -> Bool {
      return self.strength > other.strength
    }

    // Returns true if this bridge is longer than the given other one, false
    // otherwise. If the bridge lengths are tied, returns true if this bridge
    // is stronger than the other one.
    func is_longer(than other: Bridge) -> Bool {
      return self.length > other.length ||
        self.length == other.length && self.is_stronger(than: other)
    }

    // The count of components forming this bridge.
    public var length: Int {
      return components.count
    }

    // Conform to CustomStringConvertible, the components forming this bridge
    // (in order) separated by `--`.
    public var description: String {
      return components.map { "\($0)" }.joined(separator: "--")
    }

    // Represents a bridge component.
    class Component: CustomStringConvertible, Hashable {
      // "Port type" type.
      typealias Port = Int

      // Returns true if the two given components are the same, false
      // otherwise. Note that the identity of the component is checked.
      static func == (lhs: Component, rhs: Component) -> Bool {
        return lhs.id == rhs.id && lhs.ports == rhs.ports
      }

      // A unique component identifier. This is relevant if there are two
      // distinct components having the same port combination.
      let id: Int
      let ports: (Port, Port)

      // Create a component with the given id and port string description.
      // Returns nil if the port description failed to be parsed.
      init?(id: Int, desc: String) {
        let parts = desc.split(separator: "/")
        guard parts.count == 2        else { return nil }
        guard let p0 = Port(parts[0]) else { return nil }
        guard let p1 = Port(parts[1]) else { return nil }
        self.id = id
        self.ports = (p0, p1)
      }

      // Conform to Hashable.
      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      // Conform to CustomStringConvertible
      var description: String {
        return "\(ports.0)/\(ports.1)"
      }
    }
  }
}
