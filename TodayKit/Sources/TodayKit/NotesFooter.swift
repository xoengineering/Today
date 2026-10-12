import Foundation

/// The last line of a reminder's notes, when the app owns it.
///
/// Everything above the footer is the user's own text and round-trips untouched.
public enum NotesFooter {
  public static let prefix = "today:"

  /// Splits notes into the user's text and the app's metadata, if the last line carries one.
  public static func split(_ notes: String?) -> (body: String, metadata: ItemMetadata?) {
    guard let notes else { return ("", nil) }
    let trimmed = notes.trimmingTrailingNewlines()
    let lastLineStart: String.Index
    if let newline = trimmed.lastIndex(of: "\n") {
      lastLineStart = trimmed.index(after: newline)
    } else {
      lastLineStart = trimmed.startIndex
    }
    let lastLine = String(trimmed[lastLineStart...])
    guard let metadata = decode(lastLine) else { return (trimmed, nil) }
    let body = String(trimmed[..<lastLineStart]).trimmingTrailingNewlines()
    return (body, metadata)
  }

  /// Joins the user's text and the app's metadata back into notes, or nil when there is nothing to store.
  public static func join(body: String, metadata: ItemMetadata?) -> String? {
    let body = body.trimmingTrailingNewlines()
    guard let metadata else { return body.isEmpty ? nil : body }
    let footer = encode(metadata)
    return body.isEmpty ? footer : body + "\n" + footer
  }

  static func encode(_ metadata: ItemMetadata) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    // ItemMetadata holds only strings, integers, and arrays of them, so encoding cannot fail.
    let data = (try? encoder.encode(metadata)) ?? Data()
    return prefix + (String(bytes: data, encoding: .utf8) ?? "")
  }

  static func decode(_ line: String) -> ItemMetadata? {
    guard line.hasPrefix(prefix) else { return nil }
    let json = line.dropFirst(prefix.count)
    return try? JSONDecoder().decode(ItemMetadata.self, from: Data(json.utf8))
  }
}

extension String {
  fileprivate func trimmingTrailingNewlines() -> String {
    var scalars = Substring(self)
    while let last = scalars.last, last.isNewline {
      scalars = scalars.dropLast()
    }
    return String(scalars)
  }
}
