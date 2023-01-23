import Foundation
import SwiftUI
import Combine
import SafariServices.SFSafariApplication
import UIDelight

struct AutofillView: View {
    
    @ObservedObject
    var viewModel : AutofillViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            autofillDisabledAdmin
            mainStack
            Spacer()
            if !viewModel.disabledFields.isEmpty {
                disabledFields
            } else {
                howToDisableFields
            }
        }
        .modal(title: viewModel.activeLevel == .domain ? L10n.Localizable.safariAutofillDisableManuallyConfirmationTitle : L10n.Localizable.safariAutofillDisableManuallyConfirmationTitlePage,
            message: L10n.Localizable.safariAutofillDisableManuallyConfirmationMessage,
               actionTitle: L10n.Localizable.safariAutofillDisableManuallyConfirmationCTA,
               cancel: { viewModel.revertActiveValue() },
               action: { viewModel.disableAutofill() },
               shouldBePresented: $viewModel.showDisableWebsiteConfirmationAlert)
        .onAppear() {
            viewModel.activeLevel = .domain
        }
    }

    @ViewBuilder
    private var mainStack: some View {
        VStack {
            Picker("", selection: $viewModel.activeLevel, content: {
                ForEach(AutofillPolicy.Level.allCases) { level in
                    Text(level.title).tag(level)
                }
            })
                .pickerStyle(SegmentedPickerStyle())
                .padding(.trailing, 16)
                .padding(.leading, 12)
                .padding(.top, 24)
                .padding(.bottom, 24)
            Group {
                if !viewModel.viewDisabled {
                    if viewModel.pageDisabled {
                        infobox(text: L10n.Localizable.safariAutofillTurnedOff)
                            .frame(height: 28)
                            .cornerRadius(4)
                            .padding([.leading,.trailing], 20)
                            .padding(.bottom, 20)
                    }
                    else if viewModel.activeLevel == .page && viewModel.domainAutofillPolicy()?.policy == .loginPasswordsOnly {
                        infobox(text: L10n.Localizable.safariAutofillTurnedOffLoginPasswords)
                            .frame(height: 44)
                            .cornerRadius(4)
                            .padding([.leading,.trailing], 20)
                        .padding(.bottom, 20)        }
                    
                    HStack {
                        Text(L10n.Localizable.safariAutofillWhatTo)
                            .font(Typography.title)
                            .disabled(viewModel.viewDisabled)
                        
                        
                        Spacer()
                    }
                    .padding(.leading, 20)
                }

                HStack {
                    if viewModel.activeLevel == .page {
                        Text(viewModel.pageTitle)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    else {
                        Text(viewModel.domainTitle)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }


                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 24)
                selectionPicker
            }.disabled(viewModel.viewDisabled)
        }
    }

    @ViewBuilder
    private var autofillDisabledAdmin: some View {
        if viewModel.viewDisabled {
            HStack {
                Image(asset: Asset.infoboxIcon)
                    .frame(alignment: .leading)
                Text(L10n.Localizable.safariAutofillDisabledAdmin)
                    .foregroundColor(Color(asset: Asset.infoboxText))
                Spacer()
            }
            .padding()
            .backgroundColorIgnoringSafeArea(Color(asset: Asset.infobox).opacity(0.5))
            .frame(height: 28)
            .cornerRadius(4)
            .padding([.leading,.trailing], 20)
            .padding(.top, 12)
        }
    }

    private var selectionPicker: some View {
        return VStack(spacing: 24) {
            HStack {
                Picker( "",selection: $viewModel.activeValue,content: {
                    Text(AutofillPolicy.Policy.everything.title)
                        .accessibilityLabel(AutofillPolicy.Policy.everything.title)
                        .tag(AutofillPolicy.Policy.everything)

                })
                .disabled(isEverythingDisabledInPage())
                .pickerStyle(InlinePickerStyle())

                Spacer()
            }
            .padding(.leading, 12)

            HStack {
                Picker("",selection: $viewModel.activeValue,content: {
                    ForEach(AutofillPolicy.Policy.allCases) { policy in
                        if policy != .everything {
                            Text(policy.title)
                                .accessibilityLabel(policy.title)
                                .tag(policy)
                                .padding(.bottom, 16)
                        }
                    }
                })
                .pickerStyle(InlinePickerStyle())
                Spacer()

            }
            .padding(.leading, 12)
        }
        .disabled(viewModel.pageDisabled)

    }

    func infobox(text: String) -> some View {
        HStack {
            Image(asset: Asset.infoboxIcon)
                .frame(alignment: .leading)
            Button( action: {
                viewModel.resetPolicies()
            }, label: {
                Text(text)+Text("  ")+Text(L10n.Localizable.safariAutofillTurnOn)
                    .underline()
            })
            .foregroundColor(Color(asset: Asset.infoboxText))
            .buttonStyle(PlainButtonStyle())
        }
        .backgroundColorIgnoringSafeArea(Color(asset: Asset.infobox))
    }

    private func isEverythingDisabledInPage() -> Bool {
        return viewModel.activeLevel == .page && viewModel.domainAutofillPolicy()?.policy == .loginPasswordsOnly
    }
}

private extension AutofillView {

    @ViewBuilder
    var disabledFields: some View {
        Divider()
        HStack {
            Image(asset: Asset.shushDisable)
            PartlyModifiedText(text: disabledFieldsString,
                               toBeModified: L10n.Localizable.shushDashlaneLearnMore) { text in
                text.foregroundColor(.accentColor)
                    .underline(true, color: .accentColor)
            }
            .onTapGesture {
                viewModel.learnMoreShushDashlane()
            }

            Spacer()
            Button(L10n.Localizable.shushDashlaneDisabledFieldsRevert,
                   action: {
                    viewModel.revertDisabledFields()
                   })
                .buttonStyle(DashlaneDefaultButtonStyle(backgroundColor: .clear,
                                                        borderColor: Color(asset: Asset.selection),
                                                        foregroundColor: Color(asset: Asset.primaryHighlight)))
                .frame(height: 32)
        }
        .padding()
    }

    @ViewBuilder
    var howToDisableFields: some View {
        Divider()
        HStack {
            Image(asset: Asset.shushInfo)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(L10n.Localizable.shushDashlaneNoDisabledFieldsTitle)
                    .font(Typography.caption)
                Text(L10n.Localizable.shushDashlaneNoDisabledFieldsSubtitle.replacingOccurrences(of: L10n.Localizable.shushDashlaneLearnMore, with: ""))
                Button(action: viewModel.learnMoreShushDashlane) {
                    Text(L10n.Localizable.shushDashlaneLearnMore)
                        .foregroundColor(.accentColor)
                        .underline(true, color: .accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityAddTraits(.isLink)
                .accessibilityLabel(L10n.Localizable.shushDashlaneLearnMoreAccessibilityLabel)
            }
            Spacer()
        }
        .padding()
    }

    var disabledFieldsString: String {
        let count = viewModel.disabledFields.count
        if count <= 1 {
            return L10n.Localizable.shushDashlaneDisabledFieldsInfoSingular(count)
        } else {
            return L10n.Localizable.shushDashlaneDisabledFieldsInfoPlural(count)
        }
    }
}

struct CurrentWebsiteView_Previews: PreviewProvider {

    static var previews: some View {
        AutofillView(viewModel: AutofillViewModel.mock())
        AutofillView(viewModel: AutofillViewModel.mock(url: URL(string: "facebook.com")!,
                                                       rules: [.init(ruleId: "", domain: "facebook.com", newSignification: "nothing")]))
    }

}
