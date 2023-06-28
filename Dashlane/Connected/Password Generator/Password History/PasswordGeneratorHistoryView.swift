import SwiftUI
import CorePersonalData
import Combine
import CoreUserTracking
import UIDelight
import DashlaneAppKit
import IconLibrary
import DashTypes
import CoreSettings
import UIComponents
import VaultKit
import CoreLocalization

struct PasswordGeneratorHistoryView: View {
    @ObservedObject
    var model: PasswordGeneratorHistoryViewModel

    @Environment(\.toast)
    var toast

    var body: some View {
        Group {
            switch model.state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())

                case let .loaded(passwords):
                    list(for: passwords)

                case .empty:
                    emptyView
            }
        }
        .navigationTitle(CoreLocalization.L10n.Core.generatedPasswordListTitle)
        .animation(.easeOut, value: model.state)
        .reportPageAppearance(.toolsPasswordGeneratorHistory)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image.ds.historyBackup.outlined
                .foregroundColor(.ds.text.brand.quiet)
                .accessibilityHidden(true)

            Text(L10n.Localizable.generatedPasswordListEmptyTitle)
                .font(DashlaneFont.custom(26, .bold).font)
        }
    }

    private func list(for passwords: [DateGroup: [GeneratedPassword]]) -> some View {
        List {
            ForEach(DateGroup.allCases) { group in
                section(for: group, in: passwords)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color.ds.background.default.edgesIgnoringSafeArea(.all))
    }

    @ViewBuilder
    func section(for group: DateGroup, in passwords: [DateGroup: [GeneratedPassword]]) -> some View {
        if let passwords = passwords[group], !passwords.isEmpty {
            Section(header: Text(group.localizedGeneratedPasswordTitle)) {

                ForEach(passwords, id: \.id) { password in
                    let iconViewModel = model.makeDomainIconViewModel(url: password.domain)
                    PasswordGeneratedRow(generatedPassword: password, iconViewModel: iconViewModel) {

                        toast(L10n.Localizable.passwordCopiedToClipboard, image: .ds.action.copy.outlined)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        model.copy(password)
                    }
                }

            }
        }
    }
}

private struct PasswordGeneratedRow: View {
    @State
    var generatedPassword: GeneratedPassword

    @GlobalEnvironment(\.report)
    var report

    @AutoReverseState(defaultValue: false, autoReverseInterval: 10)
    var shouldReveal: Bool
    let iconViewModel: DomainIconViewModel

    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            DomainIconView(model: iconViewModel,
                                placeholderTitle: iconPlaceholderText)
            .fiberAccessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                textField
                VStack(alignment: .leading, spacing: 1) {
                    subtitle
                    Text(generatedPassword.displayedDate)
                }
                .font(.footnote)
                .foregroundColor(.ds.text.neutral.quiet)
            }
            .padding(.bottom, 5)
            .fiberAccessibilityElement(children: .ignore)
            .fiberAccessibilityAddTraits(.isButton)
            .fiberAccessibilityLabel(Text(accessibilityRowLabel))

            Image.ds.action.copy.outlined
                .foregroundColor(.ds.text.brand.quiet)
                .tapWithFeedbackForMobile(action)
                .fiberAccessibilityLabel(Text(L10n.Localizable.copyPassword))
        }
        .padding(.top, 2)
        .buttonStyle(PlainButtonStyle())

    }

    var accessibilityRowLabel: String {
        let subtitle = L10n.subtitle(for: generatedPassword)
        guard let password = generatedPassword.password else {
            return "\(subtitle)"
        }
        if shouldReveal {
            return "\(password), \(subtitle), \(L10n.Localizable.passwordHistoryHideGenerated)"
        } else {
            return "\(subtitle), \(L10n.Localizable.passwordHistoryShowGenerated)"
        }
    }

    private var iconPlaceholderText: String {
        if let domain = generatedPassword.domain?.displayDomain {
            return String(domain.prefix(2))
        } else {
            return "?"
        }
    }

    @ViewBuilder
    private var subtitle: some View {
        let subtitle = L10n.subtitle(for: generatedPassword)
        if let domain = generatedPassword.domain?.displayDomain {
            PartlyModifiedText(text: subtitle, toBeModified: domain) { text in
                text
                    .foregroundColor(.ds.text.brand.standard)
            }
        } else {
            Text(subtitle)
        }
    }

    func subtitleContent(domain: String?) -> String {
        if let domain {
            let baseText: String = generatedPassword.authId != nil ?
             L10n.Localizable.generatedPasswordSavedOn(domain) : L10n.Localizable.generatedPasswordGeneratedOn(domain)
            return baseText
        } else {
            return L10n.Localizable.generatedPasswordGeneratedNoDomain
        }
    }

    private var displayedPassword: String {
        let password = generatedPassword.password ?? ""

        if shouldReveal {
            return password
        } else {
            return String(password.prefix(17))
        }
    }

    @ViewBuilder
    private var textField: some View {
        let password = generatedPassword.password ?? ""

        ZStack {
            if shouldReveal {
                PasswordText(text: password)
            } else {
                Text(password, formatter: ObfuscatedCodeFormatter(max: 17))
                    .font(Font.system(.body, design: .monospaced))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
        .id(shouldReveal)
        .onTapGesture {
            withAnimation {
                shouldReveal.toggle()
                if shouldReveal {
                    reportReveal()
                }
            }
        }
    }
}

private extension L10n {
    static func subtitle(for generatedPassword: GeneratedPassword) -> String {
        if let domain = generatedPassword.domain?.displayDomain {
            let baseText: String = generatedPassword.authId != nil ?
             L10n.Localizable.generatedPasswordSavedOn(domain) : L10n.Localizable.generatedPasswordGeneratedOn(domain)
            return baseText
        } else {
            return L10n.Localizable.generatedPasswordGeneratedNoDomain
        }
    }
}

private extension View {
        func tapWithFeedbackForMobile(_ action: @escaping () -> Void) -> some View {
#if targetEnvironment(macCatalyst)
        self.onTapGesture(perform: action)
#else
        self.onTapWithFeedback(perform: action)
#endif
    }
}

private extension PasswordGeneratedRow {
    func reportReveal() {
        let event = UserEvent.RevealVaultItemField(field: .password,
                                                   isProtected: false,
                                                   itemId: generatedPassword.userTrackingLogID,
                                                   itemType: .generatedPassword)
        report?(event)

        if let domain = generatedPassword.domain?.domain?.name {
            report?(AnonymousEvent.RevealVaultItemField(domain: domain.hashedDomainForLogs(),
                                                        field: .password,
                                                        itemType: .generatedPassword))
        }
    }
}

struct PasswordGeneratorHistory_Previews: PreviewProvider {

    static var generatedPassword: GeneratedPassword = {
        var password = GeneratedPassword()
        password.generatedDate = Date().addingTimeInterval(-1)
        password.password = "Dashlane12"
        password.domain = PersonalDataURL(rawValue: "apple.com", domain: Domain(name: "Apple", publicSuffix: ""), host: nil)
        return password
    }()

    static var generatedPassword2: GeneratedPassword = {
        var password = GeneratedPassword()
        password.generatedDate = Date().addingTimeInterval(-40000)
        password.password = "Dashlane12asdasdasdas"
        password.domain = PersonalDataURL(rawValue: "macg.com", domain: Domain(name: "macg", publicSuffix: ""), host: nil)
        return password
    }()

    static var generatedPassword3: GeneratedPassword = {
        var password = GeneratedPassword()
        password.generatedDate = Date().addingTimeInterval(-400000)
        password.password = "Dashlane12asdasdasdas"
        password.domain = PersonalDataURL(rawValue: "macg.com", domain: Domain(name: "macg", publicSuffix: ""), host: nil)
        return password
    }()

    static var generatedPassword4: GeneratedPassword = {
        var password = GeneratedPassword()
        password.generatedDate = Date().addingTimeInterval(-8000000)
        password.password = "Dashlane12asdasdasdasDashlane12asdasdasdas"
        return password
    }()

    static let settings = UserSettings(internalStore: .mock())

    static var previews: some View {
        MultiContextPreview {
            Group {
                PasswordGeneratedRow(generatedPassword: generatedPassword, iconViewModel: .makeMock(domain: generatedPassword.domain?.domain, size: .small)) {

                }
                .previewLayout(.sizeThatFits)

                let model = PasswordGeneratorHistoryViewModel(database: ApplicationDBStack.mock(items: [generatedPassword, generatedPassword2, generatedPassword3, generatedPassword4]),
                                                              userSettings: settings,
                                                              activityReporter: .fake,
                                                              iconService: IconServiceMock())
                PasswordGeneratorHistoryView(model: model)

                let emptyModel = PasswordGeneratorHistoryViewModel(database: ApplicationDBStack.mock(),
                                                                   userSettings: settings,
                                                                   activityReporter: .fake,
                                                                   iconService: IconServiceMock())
                PasswordGeneratorHistoryView(model: emptyModel)

            }.background(Color(asset: FiberAsset.mainBackground))
        }

    }
}

private extension GeneratedPassword {
    var displayedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: generatedDate ?? Date())
    }
}

private extension DateGroup {
    var localizedGeneratedPasswordTitle: String {
        switch self {
            case .last24Hours:
                return L10n.Localizable.generatedPasswordHeaderDay
            case .lastMonth:
                return L10n.Localizable.generatedPasswordHeaderMonth
            case .lastYear:
                return L10n.Localizable.generatedPasswordHeaderYear
            case .older:
                return L10n.Localizable.generatedPasswordHeaderOlder
        }
    }
}
