import CorePersonalData
import Foundation
import LogFoundation

@Loggable
public struct AttachmentUpdateError: Error {
  @LogPublicPrivacy
  public let message: String
  public init(_ message: String) {
    self.message = message
  }
}

extension DocumentAttachable {
  public mutating func updateAttachments(with secureFileInfo: SecureFileInformation) throws {
    let newAttachment = try Attachment(from: secureFileInfo)
    self.updateAttachments(with: newAttachment)
  }

  public mutating func updateAttachments(with newAttachment: Attachment) {
    var keepingAttachments: Set<Attachment> =
      attachments?.filter { $0.id != newAttachment.id } ?? []
    keepingAttachments.insert(newAttachment)
    self.attachments = keepingAttachments
  }

  internal mutating func removeAttachment(withId id: String) throws {
    let updatedAttachments: Set<Attachment> = attachments?.filter { $0.id != id } ?? []
    attachments = updatedAttachments
  }

  public var hasAttachments: Bool {
    return self.attachments?.isEmpty == false
  }
}

extension Attachment {

  public init(from secureFileInfo: SecureFileInformation) throws {
    guard let version = Int(secureFileInfo.version),
      let localSize = Int(secureFileInfo.localSize),
      let remoteSize = Int(secureFileInfo.remoteSize),
      let creationTimeStamp: Double = secureFileInfo.creationDatetime?.timeIntervalSince1970,
      let userModificationTimeStamp: Double = secureFileInfo.userModificationDatetime?
        .timeIntervalSince1970
    else {
      throw AttachmentUpdateError("This secure file information is missing some information")
    }
    self.init(
      id: secureFileInfo.id.rawValue,
      version: version,
      type: secureFileInfo.type,
      filename: secureFileInfo.filename,
      downloadKey: secureFileInfo.downloadKey,
      cryptoKey: secureFileInfo.cryptoKey,
      localSize: localSize,
      remoteSize: remoteSize,
      creationDatetime: UInt64(creationTimeStamp),
      userModificationDatetime: UInt64(userModificationTimeStamp),
      owner: secureFileInfo.owner)
  }
}
