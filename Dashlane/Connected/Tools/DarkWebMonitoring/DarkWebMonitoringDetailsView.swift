import SwiftUI
import CorePersonalData
import Combine
import DomainParser
import UIDelight
import DashlaneAppKit
import CoreSettings
import UIComponents
import VaultKit
import DashTypes
import DesignSystem
import IconLibrary
import CoreLocalization

class DarkWebMonitoringDetailsViewModel: ObservableObject, SessionServicesInjecting {
    var breachViewModel: BreachViewModel
    var actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?

    @Published
    var shouldShowMiniBrowser: Bool

    @Published
    var advice: DarkWebMonitoringAdvice?

    lazy var miniBrowserViewModel = makeMiniBrowserViewModel()

    func makeMiniBrowserViewModel() -> MiniBrowserViewModel? {
        guard let breach = breachViewModel.simplifiedBreach, let email = breach.email, let url = breach.url.openableURL else {
            return nil
        }

        return MiniBrowserViewModel(email: email, password: initialPassword, displayableDomain: breach.url.displayDomain, url: url, domainParser: domainParser, userSettings: userSettings) { [weak self] result in
            switch result {
            case .back, .done:
                self?.shouldShowMiniBrowser = false
                if self?.initialPassword != self?.newPassword {
                    self?.newPasswordToBeSaved()
                }
            case .generatedPasswordCopiedToClipboard(let password):
                self?.newPassword = password
            }
        }
    }

    var canChangePassword: Bool {
        !correspondingCredentials.isEmpty
    }

    private var currentCredential: Credential?

    private let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
    private let correspondingCredentials: [Credential]
    private let domainParser: DomainParserProtocol
    private let userSettings: UserSettings
    private let initialPassword: String
    private var newPassword: String

    init(breach: DWMSimplifiedBreach,
         breachViewModel: BreachViewModel,
         darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
         domainParser: DomainParserProtocol,
         userSettings: UserSettings,
         actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>? = nil) {
        self.breachViewModel = breachViewModel
        self.darkWebMonitoringService = darkWebMonitoringService
        self.domainParser = domainParser
        self.userSettings = userSettings
        self.actionPublisher = actionPublisher
        self.correspondingCredentials = darkWebMonitoringService.correspondingCredentials(for: breach)

        self.currentCredential = correspondingCredentials.first
        self.shouldShowMiniBrowser = false
        self.initialPassword = correspondingCredentials.first?.password ?? ""
        self.newPassword = ""

        advice = canChangePassword ? .changePassword(changePassword) : nil
    }

    func changePassword() {
                guard !correspondingCredentials.isEmpty else {
            if miniBrowserViewModel != nil { self.shouldShowMiniBrowser = true }
            return
        }

        if let credential = correspondingCredentials.first {
            self.actionPublisher?.send(.changePassword(credential, miniBrowserViewModel != nil, { [weak self] result in
                switch result {
                    case .success: break
                    case .failure:
                        self?.shouldShowMiniBrowser = true
                }
            }))
        }
    }

    func newPasswordToBeSaved() {
        guard let credential = currentCredential else { return }
        guard let breach = breachViewModel.simplifiedBreach else { return }

        darkWebMonitoringService.saveNewPassword(for: credential, newPassword: newPassword) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let updatedCredential):
                    self.currentCredential = updatedCredential
                    self.darkWebMonitoringService.solved(breach)
                    self.advice = .savedNewPassword(self.viewItem, self.undoSavePassword)
                case .failure: self.advice = .changePassword(self.changePassword)
            }
        }
    }

    func undoSavePassword() {
        guard let credential = currentCredential else { return }

        darkWebMonitoringService.saveNewPassword(for: credential, newPassword: initialPassword) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let updatedCredential):
                    self.currentCredential = updatedCredential
                    self.advice = nil
                case .failure: self.advice = .savedNewPassword(self.viewItem, self.undoSavePassword)
            }
        }
    }

    func viewItem() {
        guard let credential = currentCredential else { return }

        self.actionPublisher?.send(.showCredential(credential))
    }
}

extension DarkWebMonitoringDetailsViewModel {
    static func fake() -> DarkWebMonitoringDetailsViewModel {
        DarkWebMonitoringDetailsViewModel(breach: DWMSimplifiedBreach(breachId: "00", url: .init(rawValue: "world.com"), leakedPassword: nil, date: nil),
                                          breachViewModel: .mock(for: .init()),
                                          darkWebMonitoringService: DarkWebMonitoringServiceMock(),
                                          domainParser: FakeDomainParser(),
                                          userSettings: .mock,
                                          actionPublisher: nil)
    }
}

struct DarkWebMonitoringDetailsView: View {

    @ObservedObject
    var model: DarkWebMonitoringDetailsViewModel

    @State private var showConfirmAlert: Bool = false

    var body: some View {
        FullScreenScrollView {
            VStack(alignment: .center, spacing: 1) {
                headerView
                detailView
                ourAdviceSection
                Spacer()
                Button(action: { showConfirmAlert.toggle() }, label: {
                    Text(L10n.Localizable.dwmDeleteAlertCta)
                        .foregroundColor(.ds.text.brand.standard)
                }).buttonStyle(BorderlessActionButtonStyle())
            }
        }
        .alert(isPresented: $showConfirmAlert, content: { alertView })
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .sheet(isPresented: $model.shouldShowMiniBrowser) {
            self.miniBrowser
        }
        .reportPageAppearance(.toolsDarkWebMonitoringAlert)
    }

    @ViewBuilder
    private var headerView: some View {
        VStack(alignment: .center, spacing: 10) {
            BreachIconView(model: model.breachViewModel.iconViewModel, iconSize: IconStyle.SizeType.small)
            Text(model.breachViewModel.url.displayDomain)
                .font(DashlaneFont.custom(20, .medium).font)
            Text(L10n.Localizable.dwmDetailViewSubtitle)
                .font(.body).foregroundColor(.ds.text.neutral.quiet).multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.ds.container.agnostic.neutral.supershy)
    }

    @ViewBuilder
    private var detailView: some View {
        VStack(spacing: 1) {
            textField(title: L10n.Localizable.dwmDetailViewBreachDate,
                      text: model.breachViewModel.displayDate)

            if let email = model.breachViewModel.email {
                textField(title: L10n.Localizable.dwmDetailViewEmailAffected, text: email)
            }

            if let leakedData = model.breachViewModel.displayLeakedData {
                textField(title: L10n.Localizable.dwmDetailViewOtherDataAffected, text: leakedData)
            }
        }
    }

    private var ourAdviceSection: some View {
        guard let advice = model.advice else { return EmptyView().eraseToAnyView() }
        return DarkWebMonitoringAdviceSection(advice: advice).eraseToAnyView()
    }

    private var alertView: Alert {
        Alert(title: Text(L10n.Localizable.dwmDetailViewDeleteConfirmTitle),
              primaryButton: Alert.Button.default(Text(CoreLocalization.L10n.Core.kwDelete), action: {
                confirmDelete()
              }),
              secondaryButton: Alert.Button.cancel()
        )
    }

    private func textField(title: String, text: String) -> some View {
        DarkWebMonitoringDetailFieldView(title: title, text: text)
    }

    private func confirmDelete() {
        guard let breach = model.breachViewModel.simplifiedBreach else { return }
        model.actionPublisher?.send(.deleteAndPop(breach))
    }

    private var miniBrowser: some View {
        if let model = model.miniBrowserViewModel {
            return NavigationView {
                MiniBrowser(model: model)
            }.eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
}

struct DarkWebMonitoringDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: false) {
            DarkWebMonitoringDetailsView(model: .fake())
        }
    }
}
