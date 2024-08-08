#if canImport(UIKit)
  import SwiftUI
  import CoreSession
  import UIDelight
  import DashTypes
  import UIComponents

  public struct LockLoadingView: View {

    let login: Login
    var start: () -> Void

    public init(login: Login, start: @escaping () -> Void) {
      self.login = login
      self.start = start
    }

    public var body: some View {
      GravityAreaVStack(
        top: LoginLogo(login: login),
        center: EmptyView()
          .navigationBarBackButtonHidden(true)
      )
      .loginAppearance()
      .onAppear(perform: {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.start()
        }
      })
      .loading(isLoading: true, loadingIndicatorOffset: true)
    }
  }

  struct LockLoadingView_Previews: PreviewProvider {

    static var previews: some View {
      MultiContextPreview {
        Group {
          LockLoadingView(login: .init("_"), start: {})
        }
      }.previewLayout(.sizeThatFits)
    }
  }
#endif
