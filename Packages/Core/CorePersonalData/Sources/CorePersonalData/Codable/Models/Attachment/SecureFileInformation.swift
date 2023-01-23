import Foundation
import DashTypes

public struct SecureFileInformation: PersonalDataCodable {
    public static let contentType: PersonalDataContentType = .secureFileInfo

    public let id: Identifier
    public var anonId: String
    public let metadata: RecordMetadata
    public var cryptoKey: String
    public var downloadKey: String
    public var filename: String
    public var localSize: String
    public var owner: String
    public var remoteSize: String
    public var type: String
    public var version: String

    public var creationDatetime: Date?
    public var userModificationDatetime: Date?
    public var spaceId: String?

    public init() {
        id = Identifier()
        anonId = UUID().uuidString
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        cryptoKey = ""
        downloadKey = ""
        filename = ""
        localSize = ""
        owner = ""
        remoteSize = ""
        type = ""
        version = ""
        creationDatetime = Date()
        userModificationDatetime = Date()
    }
}
