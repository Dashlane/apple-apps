import Combine
import CoreNetworking
import CorePersonalData
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats

public struct DocumentUpdateService {
  @Loggable
  enum DocumentDeleteError: Error {
    case fileCouldNotBeDeletedFromAWS
  }
  let database: ApplicationDatabase
  let userDeviceAPIClient: UserDeviceAPIClient

  public func deleteAllAttachments(of item: DocumentAttachable) async throws {
    try await withThrowingTaskGroup(of: Attachment?.self) { group in
      var updatingItem = item
      guard let attachments = updatingItem.attachments else { return }
      attachments.forEach { attachment in
        group.addTask { return try? await deleteAttachmentRemotely(attachment, on: item) }
      }

      var removedAttachments: [Attachment] = []
      for try await attachment in group {
        if let attachment = attachment {
          removedAttachments.append(attachment)
        }
      }

      guard !removedAttachments.isEmpty else {
        throw DocumentDeleteError.fileCouldNotBeDeletedFromAWS
      }

      removedAttachments.forEach {
        updatingItem.attachments?.remove($0)
      }
      try database.update(updatingItem)
      try self.deleteSecureFileInfo(from: removedAttachments)

      if removedAttachments.count != attachments.count {
        throw DocumentDeleteError.fileCouldNotBeDeletedFromAWS
      }
    }
  }

  public func deleteAttachment(
    _ attachment: Attachment,
    on item: DocumentAttachable
  ) async throws {
    try await deleteAttachmentRemotely(attachment, on: item)
    var updatingItem = item
    updatingItem.attachments?.remove(attachment)
    try self.database.update(updatingItem)
    try self.deleteSecureFileInfo(from: [attachment])
  }

  @discardableResult
  private func deleteAttachmentRemotely(
    _ attachment: Attachment,
    on item: DocumentAttachable
  ) async throws -> Attachment {
    _ = try await userDeviceAPIClient.securefile.deleteSecureFile(secureFileInfoId: attachment.id)
    return attachment
  }

  private func deleteSecureFileInfo(from attachments: [Attachment]) throws {
    let secureFileInfo =
      attachments
      .compactMap { attachment -> SecureFileInformation? in
        try? self.database.fetch(with: Identifier(attachment.id), type: SecureFileInformation.self)
      }

    try self.database.delete(secureFileInfo)
  }

  public func renameAttachment(
    _ attachment: Attachment,
    withName newFileName: String,
    on item: DocumentAttachable
  ) async throws {
    var updatingItem = item
    var updatingAttachment = attachment
    updatingAttachment.filename = newFileName
    updatingItem.updateAttachments(with: updatingAttachment)
    try self.database.update(updatingItem)

    if var secureFileInfo = try database.fetch(
      with: .init(attachment.id), type: SecureFileInformation.self)
    {
      secureFileInfo.filename = newFileName
      try database.save(secureFileInfo)
    }
  }
}
