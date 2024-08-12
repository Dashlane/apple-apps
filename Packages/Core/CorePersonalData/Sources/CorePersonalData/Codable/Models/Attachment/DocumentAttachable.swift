import DashTypes
import Foundation
import SwiftTreats

public protocol DocumentAttachable: PersonalDataCodable {
  var attachments: Set<Attachment>? { get set }

  var id: Identifier { get }
}

struct AnyDocumentAttachable: PersonalDataCodable {
  static var contentType: PersonalDataContentType = .secureNote

  let metadata: RecordMetadata
  let id: Identifier
  @JSONEncoded
  var attachments: Set<Attachment>?

  init(_ attachable: DocumentAttachable & PersonalDataCodable) {
    metadata = attachable.metadata
    id = attachable.id
    _attachments = .init(attachable.attachments)
  }
}

extension ApplicationDatabase {
  public func update(_ documentAttachable: DocumentAttachable) throws {
    guard !documentAttachable.metadata.id.isTemporary else {
      throw DatabaseError.cannotSaveTemporaryRecord
    }

    let any = AnyDocumentAttachable(documentAttachable)
    try save(any)
  }
}
