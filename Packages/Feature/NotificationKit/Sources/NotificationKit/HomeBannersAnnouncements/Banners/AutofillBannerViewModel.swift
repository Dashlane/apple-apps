import AuthenticationServices
import Combine
import CoreTypes
import Foundation

public class AutofillBannerViewModel: ObservableObject {

  public enum Action {
    case showAutofillDemo
  }

  private let action: (Action) -> Void

  public init(action: @escaping (Action) -> Void) {
    self.action = action
  }

  func showAutofillDemo() {
    ASSettingsHelper.openCredentialProviderAppSettings()
  }

}

extension AutofillBannerViewModel {
  public static var mock: AutofillBannerViewModel {
    AutofillBannerViewModel(action: { _ in })
  }
}
