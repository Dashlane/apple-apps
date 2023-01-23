import Foundation
public struct Bank: Decodable {
    public let code: String
    public let localizedString: String
    
}

extension Bank: RegionInformationProtocol {
    public static var resourceType: ResourceType {
        return .banks
    }
}
