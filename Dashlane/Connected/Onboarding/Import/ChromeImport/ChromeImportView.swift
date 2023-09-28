import SwiftUI
import UIDelight
import UIComponents
import DesignSystem
import CoreLocalization

struct ChromeImportView: View {

    enum Completion {
        case nextStep
        case cancel
        case back
        case importCompleted
        case importNotYetCompleted
    }

    enum Step {
        case intro
        case url
        case navigationInExtension

        func image() -> Image {
            switch self {
            case .intro:
                return Image(asset: FiberAsset.chromeImport)
            case .url:
                return Image(asset: FiberAsset.m2wConnect)
            case .navigationInExtension:
                return Image(asset: FiberAsset.chromeInstructions)
            }
        }
    }

    let step: Step
    let completion: ((Completion) -> Void)?

    @State
    var confirmationPopupShown: Bool = false

    var body: some View {
            VStack {
                Spacer()

                step.image()
                    .padding(.bottom, 73)

                description(for: step)

                Spacer()
                ctaButton(for: step)
                    .frame(maxWidth: 400)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 30)
            }
            .backgroundColorIgnoringSafeArea(Color(asset: FiberAsset.mainBackground))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingNavigationBarButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingNavigationBarButton
                }
            }
            .alert(isPresented: $confirmationPopupShown) {
                confirmationPopup
            }
            .reportPageAppearance(.importChrome)
    }

    private var confirmationPopup: Alert {
        let yesButton: Alert.Button = .default(Text(CoreLocalization.L10n.Core.m2WImportFromChromeConfirmationPopupYes), action: {
            self.completion?(.importCompleted)
        })
        let noButton: Alert.Button = .cancel(Text(CoreLocalization.L10n.Core.m2WImportFromChromeConfirmationPopupNo), action: {
            self.completion?(.importNotYetCompleted)
        })

        return Alert(title: Text(CoreLocalization.L10n.Core.m2WImportFromChromeConfirmationPopupTitle),
              primaryButton: yesButton,
              secondaryButton: noButton)
    }

    private var leadingNavigationBarButton: some View {
        if firstStep {
            return cancelButton
        } else {
            return backButton
        }
    }

    private var trailingNavigationBarButton: some View {
        if lastStep {
            return doneButton.eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }

    private var firstStep: Bool {
        switch step {
        case .intro:
            return true
        case .url, .navigationInExtension:
            return false
        }
    }

    private var lastStep: Bool {
        switch step {
        case .intro, .url:
            return false
        case .navigationInExtension:
            return true
        }
    }

    private var cancelButton: NavigationBarButton<Text> {
        NavigationBarButton(CoreLocalization.L10n.Core.m2WImportFromChromeIntoScreenCancel, action: {
            self.completion?(.cancel)
        })
    }

    private var backButton: NavigationBarButton<Text> {
        NavigationBarButton(CoreLocalization.L10n.Core.m2WImportFromChromeImportScreenBack, action: {
            self.completion?(.back)
        })
    }

    private var doneButton: NavigationBarButton<Text> {
        NavigationBarButton(action: {
            self.completion?(.nextStep)
            self.confirmationPopupShown = true
        }, label: {
            Text(CoreLocalization.L10n.Core.m2WImportFromChromeImportScreenDone).bold()
        })
    }

    private var styledPrimaryTitle: some View {
        primaryTitle(for: step)
            .frame(maxWidth: 400)
            .font(DashlaneFont.custom(26, .bold).font)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }

    private var styledSecondaryTitle: some View {
        secondaryTitle(for: step)
            .frame(maxWidth: 400)
            .font(DashlaneFont.custom(20, .medium).font)
            .foregroundColor(.ds.text.neutral.catchy)
            .padding(.horizontal, 32)
            .multilineTextAlignment(.center)
    }

    private func description(for step: Step) -> some View {
        switch step {
        case .intro, .url:
            return VStack {
                styledPrimaryTitle
                Spacer().frame(height: 24)
                styledSecondaryTitle
            }.eraseToAnyView()
        case .navigationInExtension:
            return VStack {
                styledSecondaryTitle
                Spacer().frame(height: 24)
                styledPrimaryTitle
            }.eraseToAnyView()
        }
    }

    private func primaryTitle(for step: Step) -> some View {
        switch step {
        case .intro:
            return VStack {
                Text(CoreLocalization.L10n.Core.m2WImportFromChromeIntoScreenPrimaryTitlePart1)
                    .foregroundColor(.ds.text.neutral.catchy)
                Text(CoreLocalization.L10n.Core.m2WImportFromChromeIntoScreenPrimaryTitlePart2)
                    .foregroundColor(.ds.text.neutral.catchy)
            }.eraseToAnyView()
        case .url:
            return Text(CoreLocalization.L10n.Core.m2WImportFromChromeURLScreenPrimaryTitle)
                .foregroundColor(.ds.text.neutral.catchy)
                .eraseToAnyView()
        case .navigationInExtension:
            return Text(CoreLocalization.L10n.Core.m2WImportFromChromeImportScreenPrimaryTitle)
                .foregroundColor(.ds.text.neutral.catchy)
                .eraseToAnyView()
        }
    }

    private func secondaryTitle(for step: Step) -> some View {
        switch step {
        case .intro:
            return Text(CoreLocalization.L10n.Core.m2WImportFromChromeIntoScreenSecondaryTitle).eraseToAnyView()
        case .url:
            return EmptyView().eraseToAnyView()
        case .navigationInExtension:
            return Text(CoreLocalization.L10n.Core.m2WImportFromChromeImportScreenSecondaryTitle).eraseToAnyView()
        }
    }

    @ViewBuilder
    private func ctaButton(for step: Step) -> some View {
        if let title = buttonTitle(for: step) {
            RoundedButton(title, action: {
                self.completion?(.nextStep)
            })
            .roundedButtonLayout(.fill)
        }
    }

    private func buttonTitle(for step: Step) -> String? {
        switch step {
        case .intro:
            return CoreLocalization.L10n.Core.m2WImportFromChromeIntoScreenCTA
        case .url:
            return CoreLocalization.L10n.Core.m2WImportFromChromeURLScreenCTA
        case .navigationInExtension:
            return nil
        }
    }

}

extension ChromeImportView: NavigationBarStyleProvider {
    var navigationBarStyle: UIComponents.NavigationBarStyle {
        return .transparent(tintColor: FiberAsset.dashGreenCopy.color, statusBarStyle: .default)
    }
}

struct ChromeImportView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MultiContextPreview {
                ChromeImportView(step: .intro, completion: nil)
                ChromeImportView(step: .url, completion: nil)
                ChromeImportView(step: .navigationInExtension, completion: nil)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            MultiContextPreview {
                ChromeImportView(step: .intro, completion: nil)
                ChromeImportView(step: .url, completion: nil)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

            MultiContextPreview {
                ChromeImportView(step: .intro, completion: nil)
                ChromeImportView(step: .url, completion: nil)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))

            MultiContextPreview {
                ChromeImportView(step: .intro, completion: nil)
                ChromeImportView(step: .url, completion: nil)
            }
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
        }
    }
}
