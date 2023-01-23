import Foundation

public struct TOTPActivationRequest: Encodable {
    let phoneNumber: String
    let country: String
    
    public init(phoneNumber: String, country: String) {
        self.phoneNumber = phoneNumber
        self.country = country
    }
}
