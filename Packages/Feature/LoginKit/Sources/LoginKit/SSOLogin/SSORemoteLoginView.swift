#if canImport(UIKit)
  import Foundation
  import SwiftUI

  public struct SSORemoteLoginView: View {

    @StateObject
    var model: SSORemoteLoginViewModel

    public init(model: @autoclosure @escaping () -> SSORemoteLoginViewModel) {
      self._model = .init(wrappedValue: model())
    }

    public var body: some View {
      SSOView(model: model.makeSSOViewModel())
    }
  }

  struct SSORemoteLoginView_Previews: PreviewProvider {
    static var previews: some View {
      SSORemoteLoginView(model: .mock)
    }
  }
#endif
