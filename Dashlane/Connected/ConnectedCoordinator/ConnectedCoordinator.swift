import DesignSystem
import UIKit
import SwiftUI
import CoreSession
import CoreCategorizer
import CorePersonalData
import Combine
import Lottie
import DashlaneAppKit
import SwiftTreats
import CoreSync
import LoginKit
import UIDelight
import UIComponents

class ConnectedCoordinator: NSObject, Coordinator, SubcoordinatorOwner {

    enum Tab {
        case home
        case vault
        case contacts
        case notifications
        case passwordGenerator
        case tools
        case settings

        var tabBarIndexValue: Int {
            switch self {
            case .home: return 0
            case .notifications: return 1
            case .passwordGenerator: return 2
            case .tools: return 3
            case .settings: return 4
            default: return 0 
            }
        }
    }

    let sessionServices: SessionServicesContainer
    let window: UIWindow
    var subcoordinator: Coordinator?

    let lockCoordinator: LockCoordinator
    let accessControlCoordinator: AccessControlCoordinator
    let modalCoordinator: ModalCoordinator
    let onboardingService: OnboardingService
    private let appTrackingTransparencyService: AppTrackingTransparencyService
    var subscriptions = Set<AnyCancellable>()
    private weak var logoutHandler: SessionLifeCycleHandler?
    private var syncStatusSubscription: AnyCancellable?

    private let mainMenuHandler: SessionMainMenuHandler

    let splitViewController: UISplitViewController = {
        let splitViewController: UISplitViewController
        if Device.isIpadOrMac {
            splitViewController = UISplitViewController(style: .doubleColumn)
            splitViewController.primaryBackgroundStyle = .sidebar
            splitViewController.preferredDisplayMode = .oneBesideSecondary
            splitViewController.presentsWithGesture = false
            if Device.isMac {
                splitViewController.minimumPrimaryColumnWidth = 280
                splitViewController.maximumPrimaryColumnWidth = 400
            }
            splitViewController.view.backgroundColor = .ds.background.alternate
        } else {
            splitViewController = UISplitViewController()
            splitViewController.preferredDisplayMode = .oneBesideSecondary
            splitViewController.view.backgroundColor = FiberAsset.mainBackground.color
        }

        splitViewController.turnOnToaster()

        return splitViewController
    }()

    let sessionFlowsContainer: SessionFlowsContainer

    private lazy var sidebarViewController = SidebarHostingViewController(sessionServices: sessionServices)
    private lazy var tabBarController = DashlaneTabBarController()

    var currentNavigationStyle: NavigationStyle {
        if splitViewController.viewControllers.count == 1 {
            return .tabBar
        } else {
            return .sidebar
        }
    }

    init(sessionServices: SessionServicesContainer,
         window: UIWindow,
         logoutHandler: SessionLifeCycleHandler,
         applicationMainMenuHandler: ApplicationMainMenuHandler) {
        self.window = window
        self.sessionFlowsContainer = SessionFlowsContainer(sessionServices: sessionServices)
        self.lockCoordinator = LockCoordinator(sessionServices: sessionServices,
                                               baseWindow: window)
        self.sessionServices = sessionServices
        self.accessControlCoordinator = AccessControlCoordinator(baseWindow: window,
                                                                 accessControl: sessionServices.accessControl)
        self.modalCoordinator = .init(baseWindow: window, sessionServices: sessionServices)
        self.onboardingService = sessionServices.onboardingService
        self.logoutHandler = logoutHandler
        self.appTrackingTransparencyService = AppTrackingTransparencyService(sessionServices: sessionServices)
        self.mainMenuHandler = SessionMainMenuHandler(applicationHandler: applicationMainMenuHandler,
                                                      syncService: sessionServices.syncService,
                                                      bridge: MainMenuBarBridge.shared,
                                                      logger: sessionServices.appServices.rootLogger)
    }

    func start() {
        showConnectedView()
        syncStatusSubscription = sessionServices.syncService.$syncStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.syncStatusDidChange(to: status)
        }

        if case .accountCreation = sessionServices.loadingContext {
            appTrackingTransparencyService.requestAuthorization()
        }

                if onboardingService.shouldShowAccountCreationOnboarding {
            Task {
                await DefaultAnimationCache.sharedCache.preloadAnimationsForGuidedOnboarding()
            }
        }
        configureAppearance()
    }

    func configureAppearance() {
        UITableView.appearance().backgroundColor = UIColor.ds.background.default
        UITableView.appearance().sectionHeaderTopPadding = 0.0
    }

    func dismiss(completion: @escaping () -> Void) {
        mainMenuHandler.unload()
        lockCoordinator.dismiss()
        accessControlCoordinator.dismiss()
        self.sessionFlowsContainer.flows.forEach {
            $0.value.viewController.dismiss(animated: false)
        }
        syncStatusSubscription?.cancel()
        completion()
    }

    private func showConnectedView() {
        if onboardingService.shouldShowAccountCreationOnboarding {
            showOnboarding()
        } else if let biometry = Device.biometryType, onboardingService.shouldShowFastLocalSetupForFirstLogin {
            showFastLocalSetup(for: biometry)
        } else if Device.isMac, onboardingService.shouldShowFastLocalSetupForFirstLogin {
            showFastLocalSetupForRememberMasterPassword()
        } else if onboardingService.shouldShowBrowsersExtensionsOnboarding() {
            #if targetEnvironment(macCatalyst)
            showBrowsersExtensionOnboarding()
            #else
            assertionFailure()
            #endif
        } else {
            transitionToSplitViewController()
        }
    }

                func transitionToSplitViewController() {
        let backgroundViewController = makeBackgroundViewController()
        self.window.rootViewController = splitViewController

        splitViewController.present(backgroundViewController, animated: false) {
            self.configure(self.splitViewController)
            backgroundViewController.dismiss(animated: true) {
                if self.onboardingService.shouldShowBiometricsOrPinOnboardingForSSO {
                    self.showBiometricsOrPinOnboarding()
                } else {
                    self.finishLaunch()
                }
            }
        }
    }

    func makeBackgroundViewController() -> UIViewController {
        let backgroundViewController = UIViewController()
        backgroundViewController.view = self.window.rootViewController?.view.snapshotView(afterScreenUpdates: false)
        backgroundViewController.transitioningDelegate = self
        backgroundViewController.modalPresentationStyle = .fullScreen
        return backgroundViewController
    }

        func configure(_ splitViewController: UISplitViewController) {
        if Device.isIpadOrMac {
            splitViewController.delegate = self
            setupSidebarNavigation(splitViewController, tabBarController)
        } else {
            setupTabBarNavigation(tabBarController)
            splitViewController.viewControllers = [tabBarController, makeDetailPlaceholder()]
        }
    }

    private func setupTabBarNavigation(_ tabBarController: UITabBarController) {
        tabBarController.delegate = self
        tabBarController.tabBar.barTintColor = .ds.container.agnostic.neutral.quiet
        tabBarController.tabBar.isTranslucent = true
        tabBarController.tabBar.standardAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.ds.text.brand.quiet]
        tabBarController.tabBar.standardAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.ds.text.neutral.quiet]
        tabBarController.tabBar.standardAppearance.stackedLayoutAppearance.normal.iconColor = .ds.text.neutral.quiet
        tabBarController.tabBar.standardAppearance.stackedLayoutAppearance.selected.iconColor = .ds.text.brand.quiet
        tabBarController.tabBar.scrollEdgeAppearance = tabBarController.tabBar.standardAppearance
        tabBarController.viewControllers = self.tabBarCoordinatorsSetup()
    }

    private func setupTabBarNavigationForSidebar(_ tabBarController: DashlaneTabBarController) {
        setupTabBarNavigation(tabBarController)
        tabBarController.willAppear = { [weak self] in
            guard let self = self else {
                return
            }
            tabBarController.viewControllers = self.tabBarCoordinatorsSetup()
        }

        tabBarController.willDisappear = { [weak self] in
            guard let self = self else {
                return
            }
            self.sidebarViewController.configure(with: self.sessionFlowsContainer)
        }
    }

    private func tabBarCoordinatorsSetup() -> [UIViewController] {
        var viewControllers = [UIViewController]()
        let tabBarFlows = self.sessionFlowsContainer.tabBarFlows()
        tabBarFlows.forEach { flow in
            let tabBarItem = UITabBarItem(title: flow.title,
                                          image: flow.tabBarImage.image,
                                          tag: flow.tag)
            tabBarItem.selectedImage = flow.tabBarImage.selectedImage
            let viewController = flow.viewController
            viewController.tabBarItem = tabBarItem
            viewControllers.append(viewController)

            flow.badgeValue?
                .assign(to: \.tabBarItem.badgeValue, on: viewController)
                .store(in: &self.subscriptions)
        }
        return viewControllers
    }

        private func setupSidebarNavigation(_ splitViewController: UISplitViewController, _ tabBarController: DashlaneTabBarController) {
        splitViewController.view.tintColor = .ds.text.neutral.standard
        sidebarViewController.configure(with: self.sessionFlowsContainer)
        sidebarViewController.didSelectTabFlow = { [weak self] tabFlow in
            guard let self = self else { return }
            if tabFlow.tag == ConnectedCoordinator.Tab.home.tabBarIndexValue {
                self.modalCoordinator.homeTabDidSelect()
            }
        }

        splitViewController.setViewController(makeDetailPlaceholder(), for: .secondary)
        splitViewController.setViewController(sidebarViewController, for: .primary)

        setupTabBarNavigationForSidebar(tabBarController)
        splitViewController.setViewController(tabBarController, for: .compact)
    }

    func finishLaunch() {
        sessionServices.lockService.locker.screenLocker?.suspendMomentarelyPrivacyShutter()

        self.sessionServices.appServices.notificationService.requestUserAuthorization()
        self.lockCoordinator.start()
        self.accessControlCoordinator.start()
        self.modalCoordinator.start()
        self.setupDeepLinking()
        self.lockCoordinator.showBiometryChangeIfNeeded()
        self.showVersionValidityAlertIfNeeded()
        self.configure2FAEnforcement()
        self.sessionServices.lockService.locker.didLoadSession()
    }

    private func setupDeepLinking() {
        self.sessionServices.appServices.deepLinkingService
            .deepLinkPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.didReceiveDeepLink($0)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sessionServices.appServices.deepLinkingService.resetLastLink()
                }
            }.store(in: &subscriptions)
    }

    func presentSettingsFromSidebar() {
        self.sidebarViewController.showSettings()
    }
}

extension ConnectedCoordinator: UITabBarControllerDelegate {
    fileprivate func makeDetailPlaceholder() -> UIHostingController<SplitViewPlaceholderView> {
        return UIHostingController(rootView: SplitViewPlaceholderView())
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            modalCoordinator.homeTabDidSelect()
        }
    }
}

extension ConnectedCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LockAnimator(isOpening: true)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return LockAnimator(isOpening: false)
    }
}

extension ConnectedCoordinator {
    func syncStatusDidChange(to newStatus: SyncService.SyncStatus) {
        switch newStatus {
                                        case .error(SyncError.unknownUserDevice):
            self.logoutHandler?.logoutAndPerform(action: .deleteCurrentSessionLocalData)
        #if targetEnvironment(macCatalyst)
        case .idle:
            sessionServices.appServices.safariExtensionService.performSync()
        #endif
        default:
            break
        }
    }
}

extension ConnectedCoordinator: UISplitViewControllerDelegate {
    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        DispatchQueue.main.async {
                        self.tabBarController.selectTab(.vault)
            self.tabBarController.selectTab(.home)
        }
    }

    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        DispatchQueue.main.async {
            self.sidebarViewController.selectHome()
        }
    }
}

private extension ConnectedCoordinator {
    private func showVersionValidityAlertIfNeeded() {
        sessionServices.appServices.versionValidityService.shouldShowAlertPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                let alertDismissed = { self.sessionServices.appServices.versionValidityService.messageDismissed(for: status) }
                guard let alert = VersionValidityAlert(status: status, alertDismissed: alertDismissed).makeAlert() else {
                    return
                }

                self.window.rootViewController?.present(alert, animated: true)
                self.sessionServices.appServices.versionValidityService.messageShown(for: status)
            }.store(in: &subscriptions)
    }
}

private extension AppTrackingTransparencyService {
    convenience init(sessionServices: SessionServicesContainer) {
        self.init(authenticatedABTestingService: sessionServices.authenticatedABTestingService, logger: sessionServices.appServices.rootLogger[.appTrackingTransparency])
    }
}
