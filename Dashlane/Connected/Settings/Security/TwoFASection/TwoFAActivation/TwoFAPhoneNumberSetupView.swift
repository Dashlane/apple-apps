import Foundation
import SwiftUI
import DashTypes
import DesignSystem
import CoreNetworking
import CoreSession
import UIComponents
import LoginKit
import SwiftTreats
import CoreLocalization

struct TwoFAPhoneNumberSetupView: View {

    @StateObject
    var model: TwoFAPhoneNumberSetupViewModel

    @FocusState
    var isFocused: Bool

    @Environment(\.dismiss)
    private var dismiss

    init(model: @autoclosure @escaping () -> TwoFAPhoneNumberSetupViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        ScrollView {
            ZStack {
                mainView
            }
            .animation(.easeInOut, value: model.isPhoneNumberInvalid)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.Localizable.twofaStepsNavigationTitle)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(action: dismiss.callAsFunction)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if model.inProgress {
                   ProgressView()
                } else {
                    NavigationBarButton(action: { model.complete() }, title: CoreLocalization.L10n.Core.kwNext)
                }
            }
        }
        .navigationBarStyle(.transparent)
        .reportPageAppearance(.settingsSecurityTwoFactorAuthenticationEnableBackupPhoneNumber)
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Localizable.twofaStepsCaption("2", "3"))
                .foregroundColor(.ds.text.neutral.quiet)
                .font(.callout)
            Text(L10n.Localizable.twofaPhoneTitle)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 28,
                              relativeTo: .title)
                    .weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
            VStack(alignment: .leading, spacing: 4) {
                phoneNumberView
                if model.isPhoneNumberInvalid {
                    Text(L10n.Localizable.twofaPhoneSetupWrongErrorMessage)
                        .foregroundColor(.ds.text.danger.quiet)
                        .font(.callout)
                }
            }
            .padding(.top, 24)

            Infobox(title: L10n.Localizable.twofaPhoneInfo)
                .padding(.top, model.isPhoneNumberInvalid ? 4 : 8)

            Spacer()
        }
        .padding(.all, 24)
        .onAppear {
            isFocused = true
        }
        .fullScreenCover(isPresented: $model.showError) {
            FeedbackView(title: L10n.Localizable.twofaPhoneSetupErrorTitle, message: L10n.Localizable.twofaPhoneSetupErrorMessage, primaryButton: (CoreLocalization.L10n.Core.modalTryAgain, {
                dismiss()
                model.complete()
            }), secondaryButton: (CoreLocalization.L10n.Core.cancel, {
                model.completion(nil)
            }))
        }
    }

    var phoneNumberView: some View {
        HStack(spacing: 11) {
            HStack {
                NavigationLink(destination: {
                        CountryFlagList(countryFlags: model.countryList,
                                        selectedFlag: $model.selectedCountry)

                }, label: {
                    HStack {
                        Text(model.selectedCountry.flag)
                            .font(.largeTitle)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.ds.text.neutral.quiet)
                        Divider()
                    }.fixedSize(horizontal: false, vertical: true)
                })
            }

            Text("+" + model.code)
            TextField(L10n.Localizable.twofaPhonePlaceholder, text: $model.phoneNumber)
                .keyboardType(.numberPad)
                .focused($isFocused)
            Spacer()
            Image(systemName: "xmark")
                .fiberAccessibilityLabel(Text(CoreLocalization.L10n.Core.kwDelete))
                .foregroundColor(.ds.text.neutral.standard)
                .hidden(model.phoneNumber.isEmpty)
                .contentShape(Rectangle())
                .onTapGesture {
                    model.phoneNumber = ""
                    isFocused = true
                }
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
        .background(.ds.container.agnostic.neutral.quiet)
        .clipShape(Rectangle())
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(model.isPhoneNumberInvalid ? .ds.border.danger.standard.idle : Color.clear, lineWidth: 1)
        )
        .fiberAccessibilityElement(children: .combine)
        .fiberAccessibilityLabel(Text(L10n.Localizable.twofaPhoneTitle))
    }
}

struct TwoFAPhoneNumberSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TwoFAPhoneNumberSetupView(model: .mock(.everyLogin))
        }
    }
}
