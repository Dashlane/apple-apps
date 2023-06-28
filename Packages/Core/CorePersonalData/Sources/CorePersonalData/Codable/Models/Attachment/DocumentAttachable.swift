import Foundation
import DashTypes
import SwiftTreats

public protocol DocumentAttachable: PersonalDataCodable {
        var attachments: Set<Attachment>? { get set }

        var anonId: String { get set }

    var id: Identifier { get }
}

private struct AnyDocumentAttachable: PersonalDataCodable {
        static var contentType: PersonalDataContentType = .secureNote

    let metadata: RecordMetadata
    let id: Identifier
    var anonId: String
    @JSONEncoded
    var attachments: Set<Attachment>?

    init(_ attachable: DocumentAttachable & PersonalDataCodable) {
        metadata = attachable.metadata
        id = attachable.id
        anonId = attachable.anonId
        _attachments = .init(attachable.attachments)
    }
}

public extension ApplicationDatabase {
    func update(_ documentAttachable: DocumentAttachable) throws {
        guard !documentAttachable.metadata.id.isTemporary else {
            throw DatabaseError.cannotSaveTemporaryRecord
        }

        let any = AnyDocumentAttachable(documentAttachable)
        try save(any)
    }
}
