import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

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
        return Image(.Onboarding.chromeImport)
      case .url:
        return Image(.Onboarding.m2WConnect)
      case .navigationInExtension:
        return Image(.Onboarding.chromeInstructions)
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
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        leadingNavigationBarButton
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        trailingNavigationBarButton
      }
    }
    .alert(
      CoreL10n.m2WImportFromChromeConfirmationPopupTitle,
      isPresented: $confirmationPopupShown,
      actions: {
        Button(CoreL10n.m2WImportFromChromeConfirmationPopupYes) {
          self.completion?(.importCompleted)
        }
        Button(CoreL10n.m2WImportFromChromeConfirmationPopupNo) {
          self.completion?(.importNotYetCompleted)
        }
      }
    )
    .reportPageAppearance(.importChrome)
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

  private var cancelButton: Button<Text> {
    Button(
      CoreL10n.m2WImportFromChromeIntoScreenCancel,
      action: {
        self.completion?(.cancel)
      })
  }

  private var backButton: Button<Text> {
    Button(
      CoreL10n.m2WImportFromChromeImportScreenBack,
      action: {
        self.completion?(.back)
      })
  }

  private var doneButton: Button<Text> {
    Button(
      action: {
        self.completion?(.nextStep)
        self.confirmationPopupShown = true
      },
      label: {
        Text(CoreL10n.m2WImportFromChromeImportScreenDone).bold()
      })
  }

  private var styledPrimaryTitle: some View {
    primaryTitle(for: step)
      .frame(maxWidth: 400)
      .textStyle(.specialty.spotlight.medium)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 32)
  }

  private var styledSecondaryTitle: some View {
    secondaryTitle(for: step)
      .frame(maxWidth: 400)
      .textStyle(.body.standard.strong)
      .foregroundStyle(Color.ds.text.neutral.catchy)
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
        Text(CoreL10n.m2WImportFromChromeIntoScreenPrimaryTitlePart1)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        Text(CoreL10n.m2WImportFromChromeIntoScreenPrimaryTitlePart2)
          .foregroundStyle(Color.ds.text.neutral.catchy)
      }.eraseToAnyView()
    case .url:
      return Text(CoreL10n.m2WImportFromChromeURLScreenPrimaryTitle)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .eraseToAnyView()
    case .navigationInExtension:
      return Text(CoreL10n.m2WImportFromChromeImportScreenPrimaryTitle)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .eraseToAnyView()
    }
  }

  private func secondaryTitle(for step: Step) -> some View {
    switch step {
    case .intro:
      return Text(CoreL10n.m2WImportFromChromeIntoScreenSecondaryTitle).eraseToAnyView()
    case .url:
      return EmptyView().eraseToAnyView()
    case .navigationInExtension:
      return Text(CoreL10n.m2WImportFromChromeImportScreenSecondaryTitle).eraseToAnyView()
    }
  }

  @ViewBuilder
  private func ctaButton(for step: Step) -> some View {
    if let title = buttonTitle(for: step) {
      Button(title) {
        self.completion?(.nextStep)
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
  }

  private func buttonTitle(for step: Step) -> String? {
    switch step {
    case .intro:
      return CoreL10n.m2WImportFromChromeIntoScreenCTA
    case .url:
      return CoreL10n.m2WImportFromChromeURLScreenCTA
    case .navigationInExtension:
      return nil
    }
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
