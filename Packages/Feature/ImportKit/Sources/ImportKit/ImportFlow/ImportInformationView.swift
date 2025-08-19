import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct ImportInformationView: View {

  public enum Action {
    case importCompleted(data: Data)
    case nextInfo
    case close
    case done
  }

  let model: ImportInformationViewModel
  let action: (@MainActor (Action) -> Void)?
  @Binding var isLoading: Bool

  @State
  private var showDocumentPicker = false

  @State
  private var showConfirmationPopup = false

  private var kind: ImportFlowKind {
    return model.kind
  }

  private var step: ImportInformationViewModel.Step {
    return model.step
  }

  public var body: some View {
    VStack {
      ScrollView {
        VStack(spacing: 0) {
          if let image = kind.image(for: step) {
            image
              .padding(.bottom, 73)
          }
          information
        }
        .fiberAccessibilityElement(children: .combine)
      }
      ctaButtons
        .padding(.bottom, 30)
    }
    .frame(maxHeight: .infinity)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        doneButton
      }
    }
    .reportPageAppearance(model.pageToReport)
    .documentPicker(open: kind.contentTypes, isPresented: $showDocumentPicker) { data in
      data.map { self.action?(.importCompleted(data: $0)) }
    }
    .alert(
      CoreL10n.m2WImportFromChromeConfirmationPopupTitle,
      isPresented: $showConfirmationPopup,
      actions: {
        Button(CoreL10n.m2WImportFromChromeConfirmationPopupYes) {
          Task { @MainActor in
            self.action?(.done)
          }
        }
        Button(CoreL10n.m2WImportFromChromeConfirmationPopupNo, role: .cancel) {}
      }
    )
  }
}

extension ImportInformationView {

  @ViewBuilder
  fileprivate var doneButton: some View {
    if case .extension = step {
      Button(CoreL10n.m2WImportFromChromeImportScreenDone) {
        self.showConfirmationPopup = true
      }
      .foregroundStyle(Color.ds.text.brand.standard)
    }
  }

  @ViewBuilder
  fileprivate var information: some View {
    switch (kind, step) {
    case (.chrome, .extension):
      VStack {
        styledDescription
        Spacer()
          .frame(height: 8)
        styledTitle
      }
    default:
      VStack {
        styledTitle
        Spacer()
          .frame(height: 8)
        styledDescription
      }
    }
  }

  @ViewBuilder
  fileprivate var styledTitle: some View {
    if let title = kind.title(for: step) {
      Text(title)
        .frame(maxWidth: 400)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  @ViewBuilder
  fileprivate var styledDescription: some View {
    if let description = kind.description(for: step) {
      Text(description)
        .frame(maxWidth: 400)
        .font(.body.weight(.light))
        .foregroundStyle(Color.ds.text.neutral.standard)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  @ViewBuilder
  fileprivate var ctaButtons: some View {
    switch kind {
    case .dash:
      ctaButtonsForDash
    case .keychain:
      ctaButtonsForKeychain
    case .chrome:
      ctaButtonsForChrome
    case .lastpass:
      ctaButtonsForLastpass
    }
  }

  @ViewBuilder
  fileprivate var ctaButtonsForDash: some View {
    if case .intro = step {
      Button(CoreL10n.m2WImportFromDashIntroScreenBrowse) {
        self.showDocumentPicker = true
        model.reportImportStarted()
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 16)
    }
  }

  @ViewBuilder
  fileprivate var ctaButtonsForLastpass: some View {
    if case .intro = step {
      VStack {
        Button(CoreL10n.m2WImportFromKeychainIntroScreenBrowse) {
          self.showDocumentPicker = true
          model.reportImportStarted()
        }
        .buttonDisplayProgressIndicator(isLoading)
        .buttonStyle(.designSystem(.titleOnly))
        .disabled(isLoading)
        .padding(.horizontal, 16)
      }
    }
  }

  @ViewBuilder
  fileprivate var ctaButtonsForKeychain: some View {
    if case .intro = step {
      VStack {
        Button(CoreL10n.m2WImportFromKeychainIntroScreenBrowse) {
          self.showDocumentPicker = true
          model.reportImportStarted()
        }
        .buttonStyle(.designSystem(.titleOnly))
        .padding(.horizontal, 16)

        Button(CoreL10n.m2WImportFromKeychainIntroScreenNotExported) {
          Task { @MainActor in
            self.action?(.nextInfo)
          }
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(intensity: .supershy)
      }
    } else if case .instructions = step {
      VStack {
        Button(CoreL10n.m2WImportFromKeychainURLScreenBrowse) {
          self.showDocumentPicker = true
          model.reportImportStarted()
        }
        .buttonStyle(.designSystem(.titleOnly))
        .padding(.horizontal, 16)

        Button(CoreL10n.m2WImportFromKeychainURLScreenClose) {
          Task { @MainActor in
            self.action?(.close)
          }
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(intensity: .supershy)
      }
    }
  }

  @ViewBuilder
  fileprivate var ctaButtonsForChrome: some View {
    if case .intro = step {
      Button(CoreL10n.m2WImportFromChromeIntoScreenCTA) {
        Task { @MainActor in
          self.action?(.nextInfo)
        }
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 16)
    } else if case .instructions = step {
      Button(CoreL10n.m2WImportFromChromeURLScreenCTA) {
        Task { @MainActor in
          self.action?(.nextInfo)
        }
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 16)
    }
  }

}

extension ImportFlowKind {
  fileprivate func image(for step: ImportInformationViewModel.Step) -> Image? {
    switch (self, step) {
    case (.dash, .intro):
      return Image(.dashImport)
    case (.keychain, .intro):
      return Image(.keychainImport)
    case (.keychain, .instructions):
      return Image(.keychainInstructions)
    case (.lastpass, .intro):
      return Image(.lastpassImport)
    case (.chrome, .intro):
      return Image(.chromeImport)
    case (.chrome, .instructions):
      return Image(.m2WConnect)
    case (.chrome, .extension):
      return Image(.chromeInstructions)
    default:
      return nil
    }
  }

  fileprivate func title(for step: ImportInformationViewModel.Step) -> String? {
    switch (self, step) {
    case (.dash, .intro):
      return CoreL10n.m2WImportFromDashIntroScreenPrimaryTitle
    case (.keychain, .intro):
      return CoreL10n.m2WImportFromKeychainIntroScreenPrimaryTitle
    case (.lastpass, .intro):
      return CoreL10n.importFromLastpassIntroTitle
    case (.keychain, .instructions):
      return CoreL10n.m2WImportFromKeychainURLScreenPrimaryTitle
    case (.chrome, .intro):
      return CoreL10n.m2WImportFromChromeIntroScreenPrimaryTitle
    case (.chrome, .instructions):
      return CoreL10n.m2WImportFromChromeURLScreenPrimaryTitle
    case (.chrome, .extension):
      return CoreL10n.m2WImportFromChromeImportScreenPrimaryTitle
    default:
      return nil
    }
  }

  fileprivate func description(for step: ImportInformationViewModel.Step) -> String? {
    switch (self, step) {
    case (.dash, _):
      return CoreL10n.m2WImportFromDashIntroScreenSecondaryTitle
    case (.keychain, .intro):
      return CoreL10n.m2WImportFromKeychainIntroScreenSecondaryTitle
    case (.lastpass, .intro):
      return CoreL10n.importFromLastpassIntroDescription
    case (.keychain, _):
      return CoreL10n.m2WImportFromKeychainURLScreenSecondaryTitle
    case (.chrome, .intro):
      return CoreL10n.m2WImportFromChromeIntoScreenSecondaryTitle
    case (.chrome, .extension):
      return CoreL10n.m2WImportFromChromeImportScreenSecondaryTitle
    default:
      return nil
    }
  }

}

#Preview("Dash Mock") {
  ImportInformationView(model: .dashMock, action: nil, isLoading: .constant(false))
}

#Preview("Keychain Intro Mock") {
  ImportInformationView(model: .keychainIntroMock, action: nil, isLoading: .constant(false))
}

#Preview("Keychain Instructions Mock") {
  ImportInformationView(model: .keychainInstructionsMock, action: nil, isLoading: .constant(false))
}

#Preview("Chrome Intro Mock") {
  ImportInformationView(model: .chromeIntroMock, action: nil, isLoading: .constant(false))
}

#Preview("Chrome Instructions Mock") {
  ImportInformationView(model: .chromeInstrutionsMock, action: nil, isLoading: .constant(false))
}

#Preview("Chrome Extension Mock") {
  ImportInformationView(model: .chromeExtensionMock, action: nil, isLoading: .constant(false))
}
