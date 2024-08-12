import Foundation

extension Sequence {
  public func asyncMap<T>(
    _ transform: @Sendable (Element) async throws -> T
  ) async rethrows -> [T] {
    var values: [T] = []

    for element in self {
      try await values.append(transform(element))
    }

    return values
  }

  public func asyncForEach(
    _ body: (Element) async throws -> Void
  ) async rethrows {
    for element in self {
      try await body(element)
    }
  }
}
