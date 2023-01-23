import Foundation
import CoreSettings

public struct VersionValidityStatusServerResponse: Codable, DataConvertible {
    enum Status: String, Codable {
        case validVersion = "valid_version"
        case updateRecommended = "update_recommended"
        case updateStronglyEncouraged = "update_strongly_encouraged"
        case updateRequired = "update_required"
        case expiredVersion = "expired_version"
    }

    let status: Status
    let daysBeforeExpiration: Int?
    let updatePossible: Bool?
    let helpCenterArticle: String?

    public var binaryData: Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            fatalError("Data could not be decoded")
        }
    }

    public init?(binaryData: Data) {
        guard let decodedData = try? JSONDecoder().decode(VersionValidityStatusServerResponse.self, from: binaryData) else {
            return nil
        }
        self.status = decodedData.status
        self.daysBeforeExpiration = decodedData.daysBeforeExpiration
        self.updatePossible = decodedData.updatePossible
        self.helpCenterArticle = decodedData.helpCenterArticle
    }
}
