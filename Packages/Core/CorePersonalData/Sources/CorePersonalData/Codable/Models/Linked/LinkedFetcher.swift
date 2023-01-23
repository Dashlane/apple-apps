import Foundation
import DashTypes

public protocol LinkedFetcher {
    func fetch<T: PersonalDataCodable>(with id: Identifier, type: T.Type) throws -> T?
}
