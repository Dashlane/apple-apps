import Foundation
import SwiftUI

public struct AuthenticationRequest: Decodable, Identifiable, Hashable {

    enum CodingKeys: String, CodingKey {
        case requestId = "id"
        case login
        case validity
    }
    struct Validity: Decodable, Hashable {
        enum CodingKeys: CodingKey {
            case startDate
            case expireDate
        }
        let startDate: Date
        let expireDate: Date
        init?(validity: [AnyHashable: Any]) {
            guard let start = validity[CodingKeys.startDate.stringValue] as? TimeInterval,
                  let expire = validity[CodingKeys.expireDate.stringValue] as? TimeInterval else {
                return nil
            }
            self.startDate = Date(timeIntervalSince1970: start)
            self.expireDate = Date(timeIntervalSince1970: expire)
        }
    }
    public var id: String {
        return requestId
    }

    let requestId: String
    let login: String
    let validity: Validity

    init?(userInfo: [AnyHashable: Any]) {
        guard let requestId = userInfo[CodingKeys.requestId.stringValue] as? String,
              let login = userInfo[CodingKeys.login.stringValue] as? String,
              let validityDate = userInfo[CodingKeys.validity.stringValue] as? [AnyHashable: Any],
              let validity = Validity(validity: validityDate) else {
                  return nil
              }
        self.requestId = requestId
        self.login = login
        self.validity = validity
    }

    var isExpired: Bool {
        return validity.expireDate < Date()
    }
}

extension AuthenticationRequest {

    static var mock: AuthenticationRequest {
        AuthenticationRequest(userInfo: [
            "id": "Hello",
            "login": "_",
            "validity": [
                "startDate": Date().timeIntervalSince1970,
                "expireDate": Date().addingTimeInterval(60).timeIntervalSince1970
            ]
        ])!
    }
}
