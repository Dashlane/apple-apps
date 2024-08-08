#if canImport(UIKit)
  import Foundation
  import SwiftUI

  public struct SSOLocalLoginView: View {

    @StateObject
    var model: SSOLocalLoginViewModel

    public init(model: @autoclosure @escaping () -> SSOLocalLoginViewModel) {
      self._model = .init(wrappedValue: model())
    }

    public var body: some View {
      SSOView(model: model.makeSSOViewModel())
    }
  }

  struct SSOLocalLoginView_Previews: PreviewProvider {
    static var previews: some View {
      SSOLocalLoginView(model: .mock)
    }
  }
#endif
