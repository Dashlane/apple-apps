import CoreLocalization
import DesignSystem
import DesignSystemExtra
import Foundation
import SwiftUI
import UIComponents

struct AccountRecoveryKeyPreviewView: View {
  @Environment(\.dismiss)
  var dismiss

  let recoveryKey: String

  let completion: () -> Void

  @State
  var showAlert = false

  var body: some View {
    ScrollView {
      mainView
    }
    .scrollContentBackgroundStyle(.alternate)
    .overlay(overlayButton)
    .navigationTitle(CoreL10n.recoveryKeySettingsLabel)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        NativeNavigationBarBackButton {
          showAlert = true
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        #if DEBUG
          Button(
            action: {
              UIPasteboard.general.string = recoveryKey.recoveryKeyFormatted
            },
            label: {
              Text(CoreL10n.kwCopy)
            })
        #endif
      }

    }
    .navigationBarBackButtonHidden(true)
    .alert(
      isPresented: $showAlert,
      content: {
        Alert(
          title: Text(CoreL10n.accountRecoveryKeyCancelAlertTitle),
          message: Text(CoreL10n.accountRecoveryKeyCancelAlertMessage),
          primaryButton: Alert.Button.destructive(
            Text(CoreL10n.accountRecoveryKeyCancelAlertCta),
            action: {
              dismiss()
            }),
          secondaryButton: .cancel(Text(CoreL10n.accountRecoveryKeyCancelAlertCancelCta)))
      }
    )
    .loginAppearance()
  }

  var mainView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(L10n.Localizable.recoveryKeyActivationPreviewTitle)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      message(Text(L10n.Localizable.recoveryKeyActivationPreviewMessage1))
      message(Text(L10n.Localizable.recoveryKeyActivationPreviewMessage2))
        .padding(.bottom, 16)
      Text(recoveryKey.recoveryKeyFormatted)
        .font(.system(size: 16).monospaced())
        .foregroundStyle(Color.ds.text.neutral.standard)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ds.container.agnostic.neutral.supershy)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(
          .contextMenuPreview,
          RoundedRectangle(cornerRadius: 10)
        )
        .contextMenu {
          Button(
            action: {
              UIPasteboard.general.string = recoveryKey.recoveryKeyFormatted
            },
            label: {
              Text(CoreL10n.kwCopy)
              Image(systemName: "doc.on.doc")
                .fiberAccessibilityLabel(Text(CoreL10n.kwCopy))
            })
        }
      Spacer()
    }.padding(.all, 24)
      .padding(.bottom, 24)

  }

  var overlayButton: some View {
    VStack(spacing: 24) {
      Spacer()
      Button(
        action: {
          completion()
        },
        label: {
          Text(L10n.Localizable.recoveryKeyActivationPreviewCta)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
        }
      )
      .buttonStyle(.designSystem(.titleOnly))

    }
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
  }

  func message(_ text: Text) -> some View {
    text
      .multilineTextAlignment(.leading)
      .lineLimit(nil)
      .fixedSize(horizontal: false, vertical: true)
      .foregroundStyle(Color.ds.text.neutral.standard)
      .textStyle(.body.standard.regular)
  }
}

struct AccountRecoveryKeyPreviewView_Previews: PreviewProvider {
  static var previews: some View {
    AccountRecoveryKeyPreviewView(recoveryKey: "NU6H7YTZDQNA2VQC6K56UIW1T7YN") {}
  }
}
