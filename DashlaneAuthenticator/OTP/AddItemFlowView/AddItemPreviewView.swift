import DesignSystem
import Foundation
import SwiftUI
import UIComponents
import UIDelight

struct AddItemPreviewView: View {

  let model: TokenRowViewModel
  let isFirstToken: Bool
  let completion: () -> Void

  @Environment(\.toast)
  var toast

  @State
  var showSuccess = false

  var body: some View {
    ZStack {
      mainView
      if showSuccess {
        successView
      }
    }.animation(.easeInOut, value: showSuccess)
      .animation(.easeInOut, value: isFirstToken)
  }

  var mainView: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 16) {
        Text(L10n.Localizable.addOtpPreviewTitle)
          .foregroundColor(.ds.text.neutral.catchy)
          .font(.custom(GTWalsheimPro.medium.name, size: 26))
        Text(L10n.Localizable.addOtpPreviewSubtitle(model.token.configuration.title))
          .foregroundColor(.ds.text.neutral.standard)
          .font(.body)
      }
      TokenRowView(
        model: {
          model
        }(), rowMode: .preview,
        performTrailingAction: { action in
          if case let .copy(code, _) = action {
            UIPasteboard.general.string = code
            toast(L10n.Localizable.copiedCodeToastMessage, image: .ds.action.copy.outlined)
          }
        }
      )
      .background(.ds.container.agnostic.neutral.supershy)
      .cornerRadius(8)
      Spacer()
      Button(L10n.Localizable.addOtpPreviewCta) {
        if model.token.isDashlaneOTP {
          completion()
        } else {
          showSuccess = true
        }
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
    .toasterOn()
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .navigationBarStyle(.transparent)
    .toolbar(.hidden, for: .navigationBar)
  }

  @ViewBuilder
  var successView: some View {
    if isFirstToken {
      FirstTokenSuccessView(tokenTitle: model.title, completion: completion)
    } else {
      SuccessView(completion: completion)
    }
  }
}

struct AddItemPreviewView_previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AddItemPreviewView(model: .mock(), isFirstToken: true) {

      }
    }
  }
}
