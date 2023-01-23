import Foundation

extension Definition {

public struct `Session`: Encodable {
public init(`id`: LowercasedUUID, `sequenceNumber`: Int, `serviceWorkerStartDateTime`: Date? = nil) {
self.id = id
self.sequenceNumber = sequenceNumber
self.serviceWorkerStartDateTime = serviceWorkerStartDateTime
}
public let id: LowercasedUUID
public let sequenceNumber: Int
public let serviceWorkerStartDateTime: Date?
}
}