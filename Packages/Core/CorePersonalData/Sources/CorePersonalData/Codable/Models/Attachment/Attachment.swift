import Foundation

public struct Attachment: Codable, Hashable {
    
    public let id: String
    public let version: Int
    public let type: String
    public var filename: String
    public let downloadKey: String
    public let cryptoKey: String
    public let localSize: Int
    public let remoteSize: Int
    public let creationDatetime: UInt64
    public let userModificationDatetime: UInt64
    public let owner: String
    
    public enum CodingKeys : String, CodingKey {
        case id, version, type, filename, downloadKey, cryptoKey, localSize, remoteSize, creationDatetime, userModificationDatetime, owner
    }

    public init(id: String,
                version: Int,
                type: String,
                filename: String,
                downloadKey: String,
                cryptoKey: String,
                localSize: Int,
                remoteSize: Int,
                creationDatetime: UInt64,
                userModificationDatetime: UInt64,
                owner: String) {
        self.id = id
        self.version = version
        self.type = type
        self.filename = filename
        self.downloadKey = downloadKey
        self.cryptoKey = cryptoKey
        self.localSize = localSize
        self.remoteSize = remoteSize
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.owner = owner
    }
}
