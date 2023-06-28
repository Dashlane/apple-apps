import Foundation

public protocol DatedPersonalData {
    var creationDatetime: Date? { get set }
    var userModificationDatetime: Date? { get set }
}
