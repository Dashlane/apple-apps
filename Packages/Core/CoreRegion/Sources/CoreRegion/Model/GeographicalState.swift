import Foundation

public struct GeographicalState: Decodable {
    public let code: String
    public let localizedString: String
}

extension GeographicalState: RegionInformationProtocol {
    public static var resourceType: ResourceType {
        return .geographicalStates
    }
}
