import CoreLocalization
import CorePasswords
import CorePersonalData
import CoreSpotlight
import CoreUserTracking
import DashTypes
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct PasswordGeneratorView: View {

  @Environment(\.dismiss)
  private var dismiss

  @StateObject
  var viewModel: PasswordGeneratorViewModel

  @State
  private var isInSliding = false

  let userActivityCallback: (NSUserActivity) -> Void

  public init(viewModel: @autoclosure @escaping () -> PasswordGeneratorViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
    #if !EXTENSION
      self.userActivityCallback = Self.update
    #else
      userActivityCallback = { _ in }
    #endif
  }

  public var body: some View {
    form
      .frame(maxWidth: 650)
      .frame(maxWidth: .infinity)
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .accentColor(.ds.container.expressive.brand.catchy.active)
      .userActivity(.generatePassword, userActivityCallback)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          trailingView
        }
      }
      .navigationTitle(L10n.Core.tabGeneratorTitle)
      .navigationBarTitleDisplayMode(Device.isIpadOrMac ? .inline : .automatic)
      .reportPageAppearance(.passwordGenerator)
      .onAppear {
        viewModel.refresh()
      }
      .scrollContentBackgroundStyle(.alternate)
  }

  @ViewBuilder
  var trailingView: some View {
    switch viewModel.mode {
    case let .standalone(action):
      NavigationBarButton(
        action: {
          action(.showHistory)
        },
        label: {
          Image(asset: Asset.history)
            .contentShape(Rectangle())
            .frame(width: 24, height: 24)
            .fiberAccessibilityLabel(Text(L10n.Core.generatedPasswordListTitle))
        })
    case .selection:
      EmptyView()
    }
  }

  var form: some View {
    PasswordGeneratorForm {
      Section {
        passwordView
          .buttonStyle(PlainButtonStyle())
      }
      .listRowInsets(.init(top: 0, leading: 16, bottom: 24, trailing: 16))
      .listRowSeparator(.hidden)

      Section(
        header: Text(L10n.Core.kwPadExtensionGeneratorLength.uppercased())
          + Text(": \(viewModel.preferences.length)")
      ) {
        PasswordGeneratorSliderView(viewModel: viewModel)
      }
      .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
      .listRowSeparator(.hidden)

      Section(header: Text(L10n.Core.kwPadExtensionOptions.uppercased())) {
        PasswordGeneratorViewOptions(preferences: $viewModel.preferences)
          .font(.body)
      }
      .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
      .listRowSeparator(.hidden)
    }
  }

  var passwordView: some View {
    VStack(spacing: 24) {
      PasswordSlotMachine(viewModel: viewModel)
      mainButton
    }
  }

  var mainButton: some View {
    Group {
      switch viewModel.mode {
      case let .standalone(action):
        Button(L10n.Core.passwordGeneratorCopyButton, action: viewModel.performMainAction)
          .actionSheet(item: $viewModel.pendingSaveAsCredentialPassword) { password in
            makeSavePasswordActionSheet {
              action(.createCredential(password: password))
            }
          }
      case .selection:
        Button(L10n.Core.passwordGeneratorUseButton) {
          self.viewModel.performMainAction()
          self.dismiss()
        }
      }
    }
    .buttonStyle(.designSystem(.titleOnly))
    .cornerRadius(6)
  }

  private func makeSavePasswordActionSheet(action: @escaping () -> Void) -> ActionSheet {
    ActionSheet(
      title: Text(L10n.Core.dwmOnboardingCardPWGTabEmailCopied).foregroundColor(.green),
      message: Text(L10n.Core.savePasswordMessageNewpassword),
      buttons: [
        .default(Text(L10n.Core.kwSave), action: action),
        .cancel(Text(L10n.Core.kwNotSave)),
      ])

  }
}

struct PasswordGeneratorForm<Content: View>: View {

  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    if Device.isIpadOrMac {
      Form(content: content)
        .scrollContentBackground(.hidden)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    } else {
      List(content: content)
        .listStyle(InsetGroupedListStyle())
    }

  }
}

extension List {
  @ViewBuilder
  fileprivate func generatorListStyle() -> some View {
    if Device.isIpadOrMac {
      self.listStyle(PlainListStyle())
    } else {
      self.listStyle(InsetGroupedListStyle())
    }
  }
}

struct PasswordGeneratorView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      PasswordGeneratorView(viewModel: PasswordGeneratorViewModel.mock)
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}

extension GeneratedPassword: Identifiable {}
