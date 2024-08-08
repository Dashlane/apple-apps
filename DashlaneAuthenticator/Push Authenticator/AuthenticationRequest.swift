import DashlaneAPI
import Foundation
import SwiftUI

public typealias AuthenticationRequest = UserDeviceAPIClient.Authenticator.GetPendingRequests
  .Response.RequestsElement
public typealias Validity = AuthenticationRequest.Validity

extension AuthenticationRequest: Identifiable, Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(validity)
    hasher.combine(login)
  }

  init?(userInfo: [AnyHashable: Any]) {
    guard let requestId = userInfo[CodingKeys.id.stringValue] as? String,
      let login = userInfo[CodingKeys.login.stringValue] as? String,
      let validityDate = userInfo[CodingKeys.validity.stringValue] as? [AnyHashable: Any],
      let validity = Validity(validity: validityDate)
    else {
      return nil
    }
    self.init(
      id: requestId, login: login, validity: validity, device: Device(), location: Location())
  }

  var isExpired: Bool {
    return validity.expireDate < Int(Date().timeIntervalSince1970)
  }
}

extension Validity: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(startDate)
    hasher.combine(expireDate)
  }

  init?(validity: [AnyHashable: Any]) {
    guard let start = validity[CodingKeys.startDate.stringValue] as? Int,
      let expire = validity[CodingKeys.expireDate.stringValue] as? Int
    else {
      return nil
    }
    self.init(startDate: start, expireDate: expire)
  }
}

extension AuthenticationRequest {

  static var mock: AuthenticationRequest {
    AuthenticationRequest(userInfo: [
      "id": "Hello",
      "login": "_",
      "validity": [
        "startDate": Date().timeIntervalSince1970,
        "expireDate": Date().addingTimeInterval(60).timeIntervalSince1970,
      ],
    ])!
  }
}
