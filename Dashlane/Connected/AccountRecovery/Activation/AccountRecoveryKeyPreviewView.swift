import Foundation
import SwiftUI
import UIComponents
import DesignSystem
import CoreLocalization

struct AccountRecoveryKeyPreviewView: View {
    @Environment(\.dismiss)
    var dismiss

    let recoveryKey: String

    let completion: () -> Void

    var body: some View {
        ScrollView {
            mainView
                .navigationBarStyle(.transparent)
                .hiddenNavigationTitle()
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .overlay(overlayButton)
        .navigationTitle(CoreLocalization.L10n.Core.recoveryKeySettingsLabel)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(color: .accentColor) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                #if DEBUG
                Button(action: {
                    UIPasteboard.general.string = recoveryKey.recoveryKeyFormatted
                }, label: {
                    Text(CoreLocalization.L10n.Core.kwCopy)
                })
                #endif
            }

        }
        .navigationBarBackButtonHidden(true)
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Localizable.recoveryKeyActivationPreviewTitle)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 28,
                              relativeTo: .title)
                    .weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
            message(Text(L10n.Localizable.recoveryKeyActivationPreviewMessage1))
            message(Text(L10n.Localizable.recoveryKeyActivationPreviewMessage2))
                .padding(.bottom, 16)
            Text(recoveryKey.recoveryKeyFormatted)
                .font(.system(size: 16).monospaced())
                .foregroundColor(.ds.text.neutral.standard)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.ds.container.agnostic.neutral.supershy)
                )
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = recoveryKey.recoveryKeyFormatted
                    }, label: {
                        Text(CoreLocalization.L10n.Core.kwCopy)
                        Image(systemName: "doc.on.doc")
                            .fiberAccessibilityLabel(Text(CoreLocalization.L10n.Core.kwCopy))
                    })
                }
            Spacer()
        }.padding(.all, 24)
            .padding(.bottom, 24)

    }

    var overlayButton: some View {
        VStack(spacing: 24) {
            Spacer()
            RoundedButton(L10n.Localizable.recoveryKeyActivationPreviewCta, action: { completion() })
                .roundedButtonLayout(.fill)

        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    func message(_ text: Text) -> some View {
        text
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(.ds.text.neutral.standard)
            .font(.body)
    }
}

struct AccountRecoveryKeyPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        AccountRecoveryKeyPreviewView(recoveryKey: "NU6H7YTZDQNA2VQC6K56UIW1T7YN") {}
    }
}
