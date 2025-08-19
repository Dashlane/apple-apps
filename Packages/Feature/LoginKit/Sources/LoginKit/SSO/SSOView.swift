import Foundation
import SwiftUI

public struct SSOView: View {

  @StateObject
  var model: SSOViewModel

  public init(model: @autoclosure @escaping () -> SSOViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    if model.isNitroProvider {
      ConfidentialSSOView(model: model.makeConfidentialSSOViewModel())
    } else {
      SelfHostedSSOView(model: model.makeSelfHostedSSOLoginViewModel())
    }
  }
}

struct SSOView_previews: PreviewProvider {
  static var previews: some View {
    SSOView(model: .mock)
  }
}
