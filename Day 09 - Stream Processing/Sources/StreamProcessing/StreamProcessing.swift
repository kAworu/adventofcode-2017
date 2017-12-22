// (* Stream EBNF *)
// stream    = garbage | group ;
// garbage   = "<" , { character - ">" - "!" | "!" , character } , ">" ;
// group     = "{" , [ stream { "," , stream } ] , "}" ;
// character = ? UTF-8 encoded character ? ;
public enum Stream {
  case garbage(content: String)
  case group(children: [Stream])

  public func score() -> Int {
    return score(depth: 1)
  }

  func score(depth: Int) -> Int {
    switch self {
      case .garbage:
        return 0
      case .group(let children):
        return children.reduce(depth) { $0 + $1.score(depth: depth + 1) }
    }
  }
}

/*
 * A simple LL(1) recursive descent parser w/o error handling.
 */
public class StreamProcessing {
  public static func parse(_ s: String) -> Stream? {
    return parse(Tokenizer(s))
  }

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

  static func parse_group(_ tokens: Tokenizer) -> Stream? {
    var children: [Stream] = []
    guard let lookahead = tokens.peek() else { return nil }
    switch lookahead {
      case .group_end: // empty group
        let _ = tokens.next() // eat the end-of-group token
      default:
        inside: while true { // loop parsing one child at a time.
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
}

enum Token {
  case group_begin // "{"
  case group_sep   // ","
  case group_end   // "}"
  case garbage(content: String)
}

// Peekable Garbage Tokenizer™
class Tokenizer: IteratorProtocol {
  var chars: IndexingIterator<String>
  var head: Token? = nil

  init(_ s: String) {
    chars = s.makeIterator()
    let _ = self.next() // setup self.head
  }

  func peek() -> Token? {
    return self.head
  }

  func next() -> Token? {
    let ret = head
    head = tokenize()
    return ret
  }

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

  func tokenize_garbage() -> Token? {
    var content = ""
    inside: while true {
      guard let c = chars.next() else { return nil }
      switch c {
        case "!": // garbage escape, ignore the next character
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
