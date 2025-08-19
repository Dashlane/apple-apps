import Foundation
import LogFoundation

public protocol SharingPersonalDataDB {
  func sharedItemIds() async throws -> [Identifier]

  func perform(_ updates: [SharingItemUpdate]) async throws

  func delete(with ids: [Identifier]) async throws

  func reCreateAcceptedItem(with id: Identifier, markOldItemAsPending: Bool) async throws

  func pendingUploads() async throws -> [SharingItemUpload]
  func clearPendingUploads(withIds ids: [String]) async throws

  func metadata(for ids: [Identifier]) async throws -> [SharingMetadata]

  func createSharingContents(for ids: [Identifier]) async throws -> [SharingCreateContent]
}

@Loggable
public enum SharingPermission: String, Codable, Equatable, Sendable {
  case admin
  case limited
}

public struct SharingItemUpdate: Codable, Equatable {
  public struct State: Codable, Equatable {
    public let isAccepted: Bool
    public let permission: SharingPermission

    public init(isAccepted: Bool, permission: SharingPermission) {
      self.isAccepted = isAccepted
      self.permission = permission
    }
  }

  public let id: Identifier
  public let state: State
  public let transactionContent: Data?

  public init(
    id: Identifier,
    isAccepted: Bool,
    permission: SharingPermission,
    transactionContent: Data?
  ) {
    self.id = id
    self.state = .init(isAccepted: isAccepted, permission: permission)
    self.transactionContent = transactionContent
  }

  public init(
    id: Identifier,
    state: SharingItemUpdate.State,
    transactionContent: Data?
  ) {
    self.id = id
    self.state = state
    self.transactionContent = transactionContent
  }
}

public typealias SharingTimestamp = Int

public struct SharingItemUpload: Identifiable, Equatable {
  public init(id: Identifier, uploadId: String, transactionContent: Data) {
    self.id = id
    self.uploadId = uploadId
    self.transactionContent = transactionContent
  }

  public let id: Identifier
  public let uploadId: String
  public let transactionContent: Data
}

public enum SharingType: String, Codable, Equatable, CaseIterable {
  case password
  case note
  case secret
}

public struct SharingMetadata: Hashable {
  public let title: String
  public let type: SharingType

  public init(title: String, type: SharingType) {
    self.title = title
    self.type = type
  }
}

public struct SharingCreateContent: Hashable {
  public let id: Identifier
  public let metadata: SharingMetadata
  public let transactionContent: Data

  public init(id: Identifier, metadata: SharingMetadata, transactionContent: Data) {
    self.id = id
    self.metadata = metadata
    self.transactionContent = transactionContent
  }
}
