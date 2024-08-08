import AuthenticationServices
import Combine
import DashTypes
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
    if #available(iOS 17, *) {
      ASSettingsHelper.openCredentialProviderAppSettings()
    } else {
      action(.showAutofillDemo)
    }
  }

}

extension AutofillBannerViewModel {
  public static var mock: AutofillBannerViewModel {
    AutofillBannerViewModel(action: { _ in })
  }
}
