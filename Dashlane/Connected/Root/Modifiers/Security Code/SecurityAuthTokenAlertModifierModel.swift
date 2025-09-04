import Foundation
import SwiftUI

class SecurityAuthTokenAlertModifierModel: ObservableObject, SessionServicesInjecting {
  let deepLinkingService: DeepLinkingServiceProtocol

  @Published var token: String?

  init(deepLinkingService: DeepLinkingServiceProtocol) {
    self.deepLinkingService = deepLinkingService

    deepLinkingService.deepLinkPublisher.compactMap { deepLink in
      switch deepLink {
      case let .token(token):
        guard token?.isEmpty == false else {
          return nil
        }

        return token
      default:
        return nil
      }
    }
    .receive(on: DispatchQueue.main)
    .assign(to: &$token)
  }
}
