/*
 * A simple LL(1) recursive descent parser w/o error handling.
 */
public class StreamProcessing {
  // Parse a garbage stream from a string. Returns nil on failure.
  public static func parse(_ s: String) -> Stream? {
    return parse(Tokenizer(s))
  }

  // Parse a garbage stream from a token iterator. Returns nil on failure.
  static func parse(_ tokens: Tokenizer) -> Stream? {
    guard let token = tokens.next() else { return nil }
    switch token {
      case .garbage(let content):
        return Stream.garbage(content: content)
      case .group_begin:
        return parse_group(tokens)
      default:
        return nil
    }
  }

  // Parse a group and its contained streams (recursively). Returns nil on
  // failure.
  static func parse_group(_ tokens: Tokenizer) -> Stream? {
    var children: [Stream] = []
    guard let lookahead = tokens.peek() else { return nil }
    switch lookahead {
      case .group_end: // empty group
        let _ = tokens.next() // eat the end-of-group token
      default:
        inside: while true { // parsing loop, one child per iteration.
          guard let child = parse(tokens) else { return nil }
          children.append(child)
          guard let token = tokens.next() else { return nil }
          switch token {
            case .group_sep: continue inside
            case .group_end: break inside
            default:         return nil
          }
        }
    }
    return Stream.group(children: children)
  }

  // (* Stream EBNF *)
  // stream    = garbage | group ;
  // garbage   = "<" , { character - ">" - "!" | "!" , character } , ">" ;
  // group     = "{" , [ stream { "," , stream } ] , "}" ;
  // character = ? UTF-8 encoded character ? ;
  public enum Stream {
    case garbage(content: String)
    case group(children: [Stream])

    // Returns this stream's total score.
    public var score: Int {
      return score(depth: 1)
    }

    // Returns this stream's total score at the given depth.
    func score(depth: Int) -> Int {
      switch self {
        case .garbage:
          return 0
        case .group(let children):
          return children.reduce(depth) { $0 + $1.score(depth: depth + 1) }
      }
    }

    // Return the number of characters within the garbage.
    public var garbage_count: Int {
      switch self {
        case .garbage(let content):
          return content.count
        case .group(let children):
          return children.reduce(0) { $0 + $1.garbage_count }
      }
    }
  }

  // Peekable Garbage Tokenizer™
  class Tokenizer: IteratorProtocol {
    var chars: IndexingIterator<String>
    var head: Token? = nil // can be peek()'d

    // Create a new tokenizer from a given String.
    init(_ s: String) {
      chars = s.makeIterator()
      let _ = self.next() // setup self.head
    }

    // Returns the next token without consuming it.
    func peek() -> Token? {
      return self.head
    }

    // Returns the next token and advance the iterator.
    func next() -> Token? {
      let ret = head
      head = tokenize()
      return ret
    }

    // Transform the next character(s) from the stream into a token. Returns nil
    // on failure.
    func tokenize() -> Token? {
      guard let c = chars.next() else { return nil }
      switch c {
        case "{": return Token.group_begin
        case "}": return Token.group_end
        case ",": return Token.group_sep
        case "<": return tokenize_garbage()
        default:  return nil
      }
    }

    // Consume the characters from the stream until an unescaped end-of-garbage
    // marker is found. Returns nil on error, a Token.garbage containing all the
    // unescaped consumed characters otherwise.
    func tokenize_garbage() -> Token? {
      var content = ""
      inside: while true {
        guard let c = chars.next() else { return nil }
        switch c {
          case "!": // garbage escape, ignore `c' and the next character
            let _ = chars.next()
          case ">": // end-of-garbage marker
            break inside
          default: // garbage content
            content.append(c)
        }
      }
      return Token.garbage(content: content)
    }
  }

  // Produced by the Tokenizer.
  enum Token {
    case group_begin              // "{"
    case group_sep                // ","
    case group_end                // "}"
    case garbage(content: String) // "<" ... ">"
  }
}
