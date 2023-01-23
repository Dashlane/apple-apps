import Foundation
import AVKit
import DashTypes

final class PreAccountCreationOnboardingPageVC: UIViewController {

        weak var pageControl: UIPageControl!

    var viewModel: PreAccountCreationOnboardingViewModel!

    var currentIndex: Int = -1 {
        didSet {
            pageControl.currentPage = currentIndex
            viewModel.logger.displayed(screen: .tutorialScreen(index: currentIndex))
        }
    }

    let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()

    lazy var pages: [PreAccountCreationOnboardingPage] = {

        var contents: [PreAccountCreationOnboardingPage.Content] = []
        if UIApplication.shared.canOpenURL(DashlaneURLFactory.authenticator) {
            contents.append(
            PreAccountCreationOnboardingPage.Content.init(
                transitionAnimation: nil,
                loopAnimation: .preOnboardingAuthenticatorLoop,
                titleLocalizationKey: "OnboardingV3_AuthenticatorScreen_Title",
                descriptionLocalizationKey: "OnboardingV3_AuthenticatorScreen_Description",
                isLoopAnimationOnTop: true))
        }
        contents.append(contentsOf: [
            PreAccountCreationOnboardingPage.Content.init(
                transitionAnimation: .preOnboardingTrustScreenTransition,
                loopAnimation: .preOnboardingTrustScreenLoop,
                titleLocalizationKey: "OnboardingV3_TrustScreen_Title",
                descriptionLocalizationKey: "OnboardingV3_TrustScreen_Description",
                isLoopAnimationOnTop: true),
            PreAccountCreationOnboardingPage.Content.init(
                transitionAnimation: .preOnboardingVaultScreenTransition,
                loopAnimation: .preOnboardingVaultScreenLoop,
                titleLocalizationKey: "OnboardingV3_VaultScreen_Title",
                descriptionLocalizationKey: "OnboardingV3_VaultScreen_Description",
                isLoopAnimationOnTop: false),
            PreAccountCreationOnboardingPage.Content.init(
                transitionAnimation: nil,
                loopAnimation: .preOnboardingAutofillScreenLoop,
                titleLocalizationKey: "OnboardingV3_AutofillScreen_Title",
                descriptionLocalizationKey: "OnboardingV3_AutofillScreen_Description",
                isLoopAnimationOnTop: false),
            PreAccountCreationOnboardingPage.Content.init(
                transitionAnimation: nil,
                loopAnimation: .preOnboardingSecurityAlertsScreenLoop,
                titleLocalizationKey: "OnboardingV3_SecurityAlertsScreen_Title",
                descriptionLocalizationKey: "OnboardingV3_SecurityAlertsScreen_Description",
                isLoopAnimationOnTop: false),
            PreAccountCreationOnboardingPage.Content.init(
                transitionAnimation: nil,
                loopAnimation: .preOnboardingPrivacyScreenLoop,
                titleLocalizationKey: "OnboardingV3_PrivacyScreen_Title",
                descriptionLocalizationKey: "OnboardingV3_PrivacyScreen_Description",
                isLoopAnimationOnTop: true)
        ])

        let onboardingControllers = contents.map(PreAccountCreationOnboardingPage.instantiate)

        return onboardingControllers
    }()

        override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupStackView()
        pageControl.numberOfPages = pages.count
        currentIndex = 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pages.forEach {
            $0.view.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
            stackView.addArrangedSubview($0.view)
        }
        pages.first?.loopAnimationView.play()
    }

        private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        scrollView.delegate = self
    }

    private func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
}

extension PreAccountCreationOnboardingPageVC: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width

                let absoluteProgressPoint = scrollView.contentOffset.x / pageWidth

        manageTransition(at: absoluteProgressPoint)
    }

    private func manageTransition(at absoluteProgressPoint: CGFloat) {
        guard absoluteProgressPoint >= 0 && absoluteProgressPoint <=  CGFloat(pages.count - 1) else { return }

        let firstPage = Int(absoluteProgressPoint.rounded(.down))
        let secondPage = Int(absoluteProgressPoint.rounded(.up))
        let relativeProgress = absoluteProgressPoint - CGFloat(firstPage)

        if relativeProgress == 0 {
            pages[firstPage].loopAnimationView.play()
            currentIndex = firstPage
        } else if relativeProgress == 1 {
            pages[secondPage].loopAnimationView.play()
            currentIndex = secondPage
        } else {
            if pages[firstPage].loopAnimationView.isAnimationPlaying { pages[firstPage].loopAnimationView.pause() }
            if pages[secondPage].loopAnimationView.isAnimationPlaying { pages[secondPage].loopAnimationView.pause() }
        }

                guard firstPage != secondPage else { return }

        pages[firstPage].transitionAnimationView?.currentProgress = 0.5 + relativeProgress
        pages[firstPage].animationView.alpha = 1 - relativeProgress
        pages[secondPage].transitionAnimationView?.currentProgress = relativeProgress / 2
        pages[secondPage].animationView.alpha = relativeProgress
    }
}
