import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

struct VaultItemRow: View {

    let model: VaultItemRowModel

    @State
    var showLimitedRightsAlert: Bool = false

    @Environment(\.toast)
    private var toast

    let select: (() -> Void)?

    @ScaledMetric
    private var copyPasswordIconSize: CGFloat = 24

    @ScaledMetric
    private var sharedIconSize: CGFloat = 12

    init(
        model: VaultItemRowModel,
        select: (() -> Void)? = nil
    ) {
        self.model = model
        self.select = select
    }

    var body: some View {
        HStack(spacing: 16) {
            main

            if model.quickActionsEnabled {
                quickActions
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

        @ViewBuilder
    private var main: some View {
        if let select {
            content
                .onTapWithFeedback(perform: select)
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: 16) {
            icon
            information
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var icon: some View {
        VaultItemIconView(isListStyle: true, model: model.vaultIconViewModel)
            .equatable()
    }

    private var information: some View {
        VStack(alignment: .leading, spacing: 4) {
            headline
            subtitle
        }
    }

    private var headline: some View {
        HStack(spacing: 4) {
            ItemRowInfoView(item: model.item, highlightedString: model.highlightedString, type: .title)

            if model.shouldShowSpace, let space = model.space {
                UserSpaceIcon(space: space, size: .small)
                    .equatable()
            }

            if model.shouldShowSharingStatus, model.item.metadata.isShared {
                Image.ds.shared.outlined
                    .resizable()
                    .frame(width: sharedIconSize, height: sharedIconSize)
                    .foregroundColor(.ds.text.neutral.quiet)
            }
        }
        .animation(.default, value: model.space)
        .animation(.default, value: model.item.metadata.isShared)
    }

    private var subtitle: some View {
        ItemRowInfoView(item: model.item, highlightedString: model.highlightedString, type: .subtitle)
            .font(.footnote)
    }

        @ViewBuilder
    private var quickActions: some View {
        copyPasswordButton
            .alert(isPresented: $showLimitedRightsAlert) {
                Alert(title: Text(model.item.limitedRightsAlertTitle))
            }

        if let quickActionsMenuViewModel = model.quickActionsMenuViewModel {
            QuickActionsMenuView(model: quickActionsMenuViewModel)
        }
    }

    @ViewBuilder
    private var copyPasswordButton: some View {
        if case let .credential(credential) = model.item.enumerated, !credential.password.isEmpty {
            Button {
                Task {
                    await performCopyPassword(credential.password)
                }
            } label: {
                copyPasswordIcon
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(L10n.Localizable.copyPassword))
        }
    }

    @ViewBuilder
    private var copyPasswordIcon: some View {
        Image.ds.action.copy.outlined
            .resizable()
            .frame(width: copyPasswordIconSize, height: copyPasswordIconSize)
            .foregroundColor(.ds.text.brand.standard)
    }

    private func performCopyPassword(_ password: String) async {
        guard let result = await model.copy(password, fieldType: .password) else { return }

        switch result {
        case .success:
            await UINotificationFeedbackGenerator().notificationOccurred(.success)
            toast(L10n.Localizable.pasteboardCopyPassword, image: .ds.action.copy.outlined)
        case .limitedRights:
            showLimitedRightsAlert = true
        case .authenticationDenied:
            break
        }
    }
}

struct VaultItemRow_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            List {
                Group {
                    VaultItemRow(model: .mock(item: PersonalDataMock.Credentials.instagram))
                    VaultItemRow(model: .mock(item: PersonalDataMock.Addresses.home))
                    VaultItemRow(model: .mock(item: PersonalDataMock.SecureNotes.thinkDifferent))
                    VaultItemRow(model: .mock(item: PersonalDataMock.Identities.personal))
                    VaultItemRow(model: .mock(item: PersonalDataMock.Phones.personal))
                    VaultItemRow(model: .mock(item: PersonalDataMock.Companies.dashlane))
                    VaultItemRow(model: .mock(item: PersonalDataMock.PersonalWebsites.blog))
                    VaultItemRow(model: .mock(item: PersonalDataMock.DrivingLicences.personal))
                    VaultItemRow(model: .mock(item: PersonalDataMock.SocialSecurityInformations.us))
                }
                Group {
                    VaultItemRow(model: .mock(item: PersonalDataMock.SocialSecurityInformations.gb))
                    VaultItemRow(model: .mock(item: PersonalDataMock.SocialSecurityInformations.ru))
                    VaultItemRow(model: .mock(item: PersonalDataMock.IDCards.personal))
                    VaultItemRow(model: .mock(item: PersonalDataMock.Passports.personal))
                    VaultItemRow(model: .mock(item: PersonalDataMock.BankAccounts.personal))
                }
            }

                        List(CreditCardColor.allCases, id: \.self) { color in
                VaultItemRow(model: .mock(item: PersonalDataMock.CreditCards.creditCard(withColor: color)))
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
