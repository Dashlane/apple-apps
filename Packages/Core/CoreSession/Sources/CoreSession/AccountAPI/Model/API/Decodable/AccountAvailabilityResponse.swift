import Foundation

public struct AccountAvailabilityResponse: Decodable {
    enum ExistType: String, Decodable {
        case yes
        case no
        case invalid = "no_invalid"
        case unlikely = "no_unlikely"
    }

    let exists: ExistType
    let isEuropeanUnion: Bool
    let country: String
    let sso: Bool
    let ssoServiceProviderUrl: String?
    let ssoIsNitroProvider: Bool?
    var isAccountRegistered: Bool {
        return exists == .yes
    }
}
