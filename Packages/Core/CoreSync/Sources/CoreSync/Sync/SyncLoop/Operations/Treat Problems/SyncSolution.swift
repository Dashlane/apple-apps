import CoreTypes
import Foundation

public enum SyncSolution {
  case uploadTransaction(itemIdentifier: Identifier)
  case downloadTransaction(itemIdentifier: Identifier)
}

extension SyncSolution {

  init(_ problem: SyncProblem) {
    switch problem {
    case .localObjectMoreRecent(let itemIdentifier):
      self = .uploadTransaction(itemIdentifier: itemIdentifier)
    case .objectMissingRemotely(let itemIdentifier):
      self = .uploadTransaction(itemIdentifier: itemIdentifier)
    case .objectMissingLocally(let itemIdentifier):
      self = .downloadTransaction(itemIdentifier: itemIdentifier)
    case .remoteObjectMoreRecent(let itemIdentifier):
      self = .downloadTransaction(itemIdentifier: itemIdentifier)
    }
  }

  public var isUpload: Bool {
    switch self {
    case .uploadTransaction:
      return true
    case .downloadTransaction:
      return false
    }
  }

  public var isDownload: Bool {
    switch self {
    case .uploadTransaction:
      return false
    case .downloadTransaction:
      return true
    }
  }

  var identifier: Identifier {
    switch self {
    case .downloadTransaction(let id):
      return id
    case .uploadTransaction(let id):
      return id
    }
  }

}
