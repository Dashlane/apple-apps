import Foundation
import SwiftUI
import UIDelight
import UIComponents
import DesignSystem
import CoreLocalization

struct RecoveryCodesView: View {

    @StateObject
    var model: RecoveryCodesViewModel

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ScrollView {
            mainView
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(L10n.Localizable.twofaStepsNavigationTitle)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButton(action: dismiss.callAsFunction)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationBarButton(action: model.completion, title: L10n.Localizable.kwSkip)
                            .foregroundColor(.ds.text.neutral.standard)
                    }
                }
        }
        .overlay(overlayButton)
        .activitySheet($model.activityItem) { _, _, _, _ in
            model.showActivityCompletionAlert = true
        }
        .alert(isPresented: $model.showActivityCompletionAlert) {
            Alert(title: Text(L10n.Localizable.saveRecoverycodesAlertTitle),
                  message: Text(L10n.Localizable.saveRecoverycodesAlertMessage),
                  primaryButton: .cancel(Text(L10n.Localizable.saveRecoverycodesAlertCancelCta)),
                  secondaryButton: .default(Text(L10n.Localizable.saveRecoverycodesAlertDoneCta), action: model.completion))
        }
        .reportPageAppearance(.settingsSecurityTwoFactorAuthenticationEnableBackupCodes)
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Localizable.twofaStepsCaption("3", "3"))
                .foregroundColor(.ds.text.neutral.quiet)
                .font(.callout)
            Text(L10n.Localizable.twofaRecoveryCodesTitle)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 28,
                              relativeTo: .title)
                    .weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
            codesView
                .padding(.top, 24)
            Infobox(title: L10n.Localizable.twofaRecoveryCodesInfo)
                .padding(.top, 8)
            Spacer()
        }
        .padding(.all, 24)
        .padding(.bottom, 60)
    }

    var codesView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n.Localizable.twofaRecoveryCodesSubtitle)
                .font(.callout)
                .foregroundColor(.ds.text.neutral.quiet)
            Text(model.codes.joined(separator: "\n"))
                .font(.system(size: 16).monospaced())
                .foregroundColor(.ds.text.neutral.standard)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.ds.container.agnostic.neutral.quiet)
            .clipShape(Rectangle())
            .cornerRadius(8)
            .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = model.codes.joined(separator: "\n")
                    }, label: {
                        Text(CoreLocalization.L10n.Core.kwCopy)
                        Image(systemName: "doc.on.doc")
                            .fiberAccessibilityLabel(Text(CoreLocalization.L10n.Core.kwCopy))
                    })
                 }
        }
    }

    var overlayButton: some View {
        VStack {
            Spacer()
            RoundedButton(L10n.Localizable.twofaRecoveryCodesCta) {
                model.activityItem = ActivityItem(items: model.codes.joined(separator: "\n"), activities: nil)
            }
            .roundedButtonLayout(.fill)
        }
        .padding(24)
    }
}

struct RecoveryCodesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryCodesView(model: RecoveryCodesViewModel(codes: [ "VKLLSDRFVCDFREZA",
                                                                     "DRFVCDFREZAVKLLS",
                                                                     "DFREZVKLLSDRFVCA",
                                                                     "VDRFVCDFREZAKLLS",
                                                                     "DRFVCDFRVKLLSEZA",
                                                                     "KLLSDRFVRFVCDFRV",
                                                                     "LSDRFVCDFREZAVCD",
                                                                     "SDRFVCDFREZAZVKL",
                                                                     "RFVCDFREZAZVKLWQ",
                                                                     "DFREZAZVKLWQAA23"]) {})
        }
    }
}

class RecoveryCodesViewModel: ObservableObject {
    let codes: [String]
    @Published
    var activityItem: ActivityItem?

    @Published
    var showActivityCompletionAlert: Bool {
        didSet {
            print(showActivityCompletionAlert)
        }
    }
    let completion: () -> Void

    init(codes: [String],
         completion: @escaping () -> Void) {
        self.codes = codes
        self.activityItem = nil
        self.showActivityCompletionAlert = false
        self.completion = completion
    }
}
