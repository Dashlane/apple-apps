import AuthenticationServices
import Combine
import CoreFeature
import CorePersonalData
import CoreTypes
import Foundation
import SwiftTreats

public protocol AutofillStateServiceProtocol {
  var activationStatus: AutofillActivationStatus { get }
  var activationStatusPublisher: AnyPublisher<AutofillActivationStatus, Never> { get }

  func unload(shouldClear: Bool) async

  func save(_ credential: Credential, oldCredential: Credential?) async
  func save(_ passkey: Passkey, oldPasskey: Passkey?) async

}

public struct AutofillServiceMock: AutofillStateServiceProtocol {
  public var activationStatus: CoreTypes.AutofillActivationStatus = .disabled

  public var activationStatusPublisher: AnyPublisher<CoreTypes.AutofillActivationStatus, Never> {
    Just(activationStatus).eraseToAnyPublisher()
  }

  public func unload(shouldClear: Bool) async {
  }

  public func save(_ credential: Credential, oldCredential: Credential?) async {
  }

  public func save(_ passkey: Passkey, oldPasskey: Passkey?) async {
  }
}

extension AutofillStateServiceProtocol where Self == AutofillServiceMock {
  public static var mock: AutofillServiceMock {
    AutofillServiceMock()
  }
}
