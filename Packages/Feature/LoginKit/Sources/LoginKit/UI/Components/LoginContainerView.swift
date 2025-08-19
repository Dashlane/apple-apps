import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct LoginContainerView<TopView: View, CenterView: View, BottomView: View>: View {
  private let topView: TopView
  private let centerView: CenterView
  private let bottomView: BottomView

  init(
    @ViewBuilder topView: @escaping () -> TopView,
    @ViewBuilder centerView: @escaping () -> CenterView,
    @ViewBuilder bottomView: @escaping () -> BottomView
  ) {
    self.topView = topView()
    self.centerView = centerView()
    self.bottomView = bottomView()
  }

  init(topView: TopView, centerView: CenterView, bottomView: BottomView) {
    self.topView = topView
    self.centerView = centerView
    self.bottomView = bottomView
  }

  var body: some View {
    Group {
      if Device.is(.pad, .mac, .vision) {
        ipadMacLayout
      } else {
        iphoneLayout
      }
    }
    .loginAppearance()
  }

  private var iphoneLayout: some View {
    VStack(spacing: 12) {
      topView
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 58)
      centerView
        .padding(.top, 44)
        .frame(maxHeight: .infinity, alignment: .top)
      bottomView
    }
    .padding(.horizontal, 20)
  }

  private var ipadMacLayout: some View {
    VStack(alignment: .center, spacing: 24) {
      topView
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 20)
      centerView
      bottomView
    }
    .padding(.horizontal, 20)
    .frame(alignment: .center)
  }
}

#Preview {
  LoginContainerView(
    topView: {
      VStack(spacing: 38) {
        LoginLogo(login: .init("_"))
        Button(
          action: {},
          label: {
            Image.ds.faceId.outlined
              .resizable()
              .frame(width: 40, height: 40)
              .foregroundStyle(Color.ds.text.brand.standard)
          }
        )
      }
    },
    centerView: {
      DS.PasswordField("Master Password", text: .constant("_Pa33w0rd"))
    },
    bottomView: {
      VStack(spacing: 8) {
        if Device.is(.pad, .mac, .vision) {
          Button("Login", action: {})
        }
        Button("Forgot Password?", action: {})
          .style(intensity: .supershy)
          .padding(.bottom, 12)
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
  )
}
