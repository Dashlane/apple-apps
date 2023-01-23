import Foundation
import SwiftUI
import Combine
import CorePersonalData
import CorePremium
import CoreSettings
import SwiftTreats
import SecurityDashboard

@MainActor
class ToolsFlowViewModel: ObservableObject, TabCoordinator, SessionServicesInjecting {

    enum Step: Equatable {
        case root
        case item(ToolsItem)
        case placeholder(ToolsItem)
        case unresolvedAlert(TrayAlertContainer)
    }

    enum Sheet: Identifiable, Equatable {
        case showM2W(String?)
        case vpnPremiumPaywall
        case vpnB2BDisabled

        var id: String {
            switch self {
            case let .showM2W(origin):
                return "showM2w\(origin ?? "")"
            case .vpnPremiumPaywall:
                return "vpnPremiumPaywall"
            case .vpnB2BDisabled:
                return "vpnB2BDisabled"
            }
        }
    }

    @Published
    var presentedSheet: Sheet?

        let tag: Int = 0
    let id: UUID = .init()

    lazy var viewController: UIViewController = {
        UIHostingController(rootView: ToolsFlow(viewModel: self))
    }()

    let title: String
    let tabBarImage: NavigationImageSet
    let sidebarImage: NavigationImageSet

    @Published
    var steps: [Step]

    let capabilityService: CapabilityServiceProtocol
    let userSettings: UserSettings
    let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
    let vpnService: VPNServiceProtocol
    let toolsViewModelFactory: ToolsViewModel.Factory
    let passwordHealthFlowViewModelFactory: PasswordHealthFlowViewModel.Factory
    let authenticatorToolFlowViewModelFactory: AuthenticatorToolFlowViewModel.Factory
    let passwordGeneratorToolsFlowViewModelFactory: PasswordGeneratorToolsFlowViewModel.Factory
    let vpnAvailableToolsFlowViewModelFactory: VPNAvailableToolsFlowViewModel.Factory
    let sharingToolsFlowViewModelFactory: SharingToolsFlowViewModel.Factory
    let darkWebToolsFlowViewModelFactory: DarkWebToolsFlowViewModel.Factory
    let unresolvedAlertViewModelFactory: UnresolvedAlertViewModel.Factory

    let didSelectItem = PassthroughSubject<ToolsItem, Never>()
    var cancellables = Set<AnyCancellable>()
    let deepLinkingService: DeepLinkingServiceProtocol

    let detailInformationValue: CurrentValueSubject<TabElementDetail, Never>? = .init(.text(""))

    init(toolsItem: ToolsItem?,
         userSettings: UserSettings,
         vpnService: VPNServiceProtocol,
         capabilityService: CapabilityServiceProtocol,
         deepLinkingService: DeepLinkingServiceProtocol,
         darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
         toolsViewModelFactory: ToolsViewModel.Factory,
         passwordHealthFlowViewModelFactory: PasswordHealthFlowViewModel.Factory,
         authenticatorToolFlowViewModelFactory: AuthenticatorToolFlowViewModel.Factory,
         passwordGeneratorToolsFlowViewModelFactory: PasswordGeneratorToolsFlowViewModel.Factory,
         vpnAvailableToolsFlowViewModelFactory: VPNAvailableToolsFlowViewModel.Factory,
         sharingToolsFlowViewModelFactory: SharingToolsFlowViewModel.Factory,
         darkWebToolsFlowViewModelFactory: DarkWebToolsFlowViewModel.Factory,
         unresolvedAlertViewModelFactory: UnresolvedAlertViewModel.Factory) {
        self.userSettings = userSettings
        self.vpnService = vpnService
        self.capabilityService = capabilityService
        self.deepLinkingService = deepLinkingService
        self.darkWebMonitoringService = darkWebMonitoringService
        self.toolsViewModelFactory = toolsViewModelFactory
        self.passwordHealthFlowViewModelFactory = passwordHealthFlowViewModelFactory
        self.authenticatorToolFlowViewModelFactory = authenticatorToolFlowViewModelFactory
        self.passwordGeneratorToolsFlowViewModelFactory = passwordGeneratorToolsFlowViewModelFactory
        self.vpnAvailableToolsFlowViewModelFactory = vpnAvailableToolsFlowViewModelFactory
        self.sharingToolsFlowViewModelFactory = sharingToolsFlowViewModelFactory
        self.darkWebToolsFlowViewModelFactory = darkWebToolsFlowViewModelFactory
        self.unresolvedAlertViewModelFactory = unresolvedAlertViewModelFactory

        self.title = toolsItem?.title ?? L10n.Localizable.tabToolsTitle
        let tabBarSet = NavigationImageSet(image: FiberAsset.tabIconToolsOff,
                                           selectedImage: FiberAsset.tabIconToolsOn)
        self.tabBarImage = toolsItem?.tabBarImage ?? tabBarSet
        self.sidebarImage = toolsItem?.sidebarImage ?? tabBarSet

        if let toolsItem {
            steps = []
            setupSecondaryView(for: toolsItem)
            setupDetailInformationValue(for: toolsItem)
        } else {
            steps = [.root]
        }

        didSelectItem.sink { [weak self] item in
            guard let self else { return }
            self.didSelect(item: item)
        }.store(in: &cancellables)
    }

    func start() {

    }

    func setupDetailInformationValue(for toolsItem: ToolsItem) {
        let data = ToolsViewCellData(withItem: toolsItem, capabilityService: capabilityService)

        data.badgeConfiguration.sink { [weak self] configuration in
            guard let self else { return }
            guard let configuration else {
                self.detailInformationValue?.send(.text(""))
                return
            }
            let detail = TabElementDetail.badge(configuration)
            self.detailInformationValue?.send(detail)
        }
        .store(in: &cancellables)
    }

    func didSelect(item: ToolsItem) {
        setupSecondaryView(for: item)
        switch item {
        case .secureWifi:
            guard !vpnService.isAvailable else {
                return
            }
            if !vpnService.capabilityIsEnabled && vpnService.reasonOfUnavailability != .team {
                self.presentedSheet = .vpnPremiumPaywall
            } else {
                self.presentedSheet = .vpnB2BDisabled
            }
        case .multiDevices:
            presentedSheet = .showM2W("tools")
        case .darkWebMonitoring:
            guard darkWebMonitoringService.isDwmEnabled else {
                deepLinkingService.handleLink(.planPurchase(initialView: .paywall(key: .securityBreach)))
                return
            }
            fallthrough
        default:
            break
        }
    }

    func setupSecondaryView(for item: ToolsItem) {

        if case let .item(lastItem) = steps.last, item == lastItem {
                        return
        }

        switch item {
        case .secureWifi:
            if vpnService.isAvailable {
                self.steps.append(.item(.secureWifi))
            } else if Device.isIpadOrMac {
                self.steps = [.placeholder(.secureWifi)]
            }
        case .darkWebMonitoring:
            if darkWebMonitoringService.isDwmEnabled {
                self.steps.append(.item(.darkWebMonitoring))
            } else if Device.isIpadOrMac {
                self.steps = [.placeholder(.darkWebMonitoring)]
            }
        case .multiDevices:
                        if Device.isIpadOrMac {
                self.steps = [.placeholder(.multiDevices)]
            }
        default:
            self.steps.append(.item(item))
        }
    }

    func makeM2WViewModel(origin: String?) -> M2WFlowViewModel {
        let initialStep = M2WFlowStep(origin: .init(string: origin))
        return M2WFlowViewModel(initialStep: initialStep)
    }

    func dismissM2W(dismissAction: M2WDismissAction) {
        switch dismissAction {
        case .success:
            let settings = M2WSettings(userSettings: userSettings)
            settings.setUserHasFinishedM2W()
            fallthrough
        default:
            presentedSheet = nil
        }
    }
}

extension ToolsFlowViewModel {
    static func mock(item: ToolsItem?,
                     vpnService: VPNServiceProtocol = .mockAvailable(),
                     darkWebMonitoringService: DarkWebMonitoringServiceProtocol = .mockAvailable()) -> ToolsFlowViewModel {
        return .init(toolsItem: item,
                     userSettings: .mock,
                     vpnService: vpnService,
                     capabilityService: CapabilityServiceMock(),
                     deepLinkingService: DeepLinkingService.fakeService,
                     darkWebMonitoringService: DarkWebMonitoringServiceMock(),
                     toolsViewModelFactory: .init({ _ in .mock }),
                     passwordHealthFlowViewModelFactory: .init({ _ in .mock }),
                     authenticatorToolFlowViewModelFactory: .init({ .mock }),
                     passwordGeneratorToolsFlowViewModelFactory: .init({ .mock }),
                     vpnAvailableToolsFlowViewModelFactory: .init({ .mock }),
                     sharingToolsFlowViewModelFactory: .init({ .mock }),
                     darkWebToolsFlowViewModelFactory: .init({ .mock }),
                     unresolvedAlertViewModelFactory: .init({ .mock }))
    }
}
