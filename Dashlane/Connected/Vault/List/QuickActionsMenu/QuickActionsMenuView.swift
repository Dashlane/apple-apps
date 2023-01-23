import SwiftUI
import CorePersonalData
import UIDelight
import Combine
import CoreUserTracking
import DashlaneAppKit
import VaultKit
import CoreSharing
import CoreFeature
import DesignSystem

struct QuickActionsMenuView: View {

    let model: QuickActionsMenuViewModel

    @State
    private var showLimitedRightsAlert: Bool = false

    @Environment(\.toast)
    private var toast

    @State
    private var deleteRequest: DeleteVaultItemRequest = .init()

    @State
    private var showSharingDisabledAlert: Bool = false

    @State
    private var showSharingFlow: Bool = false

    @State
    private var showSharing: Bool = false

    var body: some View {
        Menu {
            VaultItemMenuContent(item: model.item, copy: model.copy)
            shareButton
            DeleteMenuButton {
                Task {
                    deleteRequest.itemDeleteBehavior = try await model.deleteBehaviour()
                    deleteRequest.isPresented = true
                }
            }
        } label: {
            Image.ds.action.more.outlined
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibility(label: Text(L10n.Localizable.kwActions))
                .frame(width: 24, height: 40)
                .foregroundColor(.ds.text.brand.standard)
                .onReceive(model.copyResultPublisher, perform: onCopyAction)
                .alert(isPresented: $showLimitedRightsAlert) {
                    Alert(title: Text(model.item.limitedRightsAlertTitle))
                }
        }
        .deleteItemAlert(request: $deleteRequest, deleteAction: model.delete)
        .background {
                        Rectangle().foregroundColor(.clear)
                .alert(isPresented: $showSharingDisabledAlert) {
                    Alert(model.sharingDeactivationReason ?? .b2bSharingDisabled)
                }
        }
        .onTapGesture(perform: {
            model.reportAppearance()
        })
        .sheet(isPresented: $showSharing) {
            ShareFlowView(model: self.model.shareFlowViewModelFactory.make(items: [self.model.item]))
        }
    }

    private func onCopyAction(_ result: VaultItemRowModel.CopyResult) {
        switch result {
        case .success(let fieldType):
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            toast(fieldType.pasteboardMessage, image: .ds.action.copy.outlined)
        case .limitedRights:
            self.showLimitedRightsAlert = true
        case .authenticationDenied:
            break
        }
    }

}

extension QuickActionsMenuView {
        @ViewBuilder
    var shareButton: some View {
        if !model.item.hasAttachments && model.item.metadata.isShareable {
            Button {
                if model.sharingDeactivationReason != nil {
                    showSharingDisabledAlert = true
                } else {
                    self.showSharing = true
                }
            } label: {
                HStack {
                    Text(L10n.Localizable.shareQuickAction)
                    Image(asset: FiberAsset.shareIcon)
                }
            }
        }
    }
}

extension Definition.Field {
    var pasteboardMessage: String {
        switch self {
        case .password:         return L10n.Localizable.pasteboardCopyPassword
        case .email:            return L10n.Localizable.pasteboardCopyEmail
        case .login:            return L10n.Localizable.pasteboardCopyLogin
        case .secondaryLogin:   return L10n.Localizable.pasteboardCopySecondaryLogin
        case .cardNumber:       return L10n.Localizable.pasteboardCopyCardNumber
        case .securityCode:     return L10n.Localizable.pasteboardCopySecurityCode
        case .iban:             return L10n.Localizable.pasteboardCopyIban
        case .bic:              return L10n.Localizable.pasteboardCopyBic
        case .number:           return L10n.Localizable.pasteboardCopyNumber
        case .fiscalNumber:     return L10n.Localizable.pasteboardCopyFiscalNumber
        case .otpCode:          return L10n.Localizable.pasteboardCopyOtpCode
        default: return L10n.Localizable.kwCopied
        }
    }
}

struct QuickActionsMenuView_Previews: PreviewProvider {
    private static var company: Company {
        var company = Company()
        company.name = "blabalbal"
        company.jobTitle = "android dev"
        return company
    }

    static var previews: some View {
        MultiContextPreview {
            QuickActionsMenuView(model: .mock(item: company))
                .background(Color.ds.container.agnostic.neutral.supershy)
        }
        .previewLayout(.sizeThatFits)
    }
}
