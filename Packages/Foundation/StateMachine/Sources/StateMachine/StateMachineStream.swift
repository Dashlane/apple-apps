import Foundation

public struct StateMachineStream<Element: Sendable>: Hashable {
  let id: UUID
  public let stream: AsyncStream<Element>
  public let continuation: AsyncStream<Element>.Continuation

  public init() {
    self.id = UUID()
    let stream = AsyncStream.makeStream(of: Element.self)
    self.continuation = stream.continuation
    self.stream = stream.stream
  }

  public static func == (lhs: StateMachineStream, rhs: StateMachineStream) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
