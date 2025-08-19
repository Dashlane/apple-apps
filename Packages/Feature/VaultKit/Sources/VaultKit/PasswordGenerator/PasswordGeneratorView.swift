import CoreLocalization
import CorePasswords
import CorePersonalData
import CoreSpotlight
import CoreTypes
import CoreUserTracking
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

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
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .tint(.ds.container.expressive.brand.catchy.active)
      .userActivity(.generatePassword, userActivityCallback)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          trailingView
        }
      }
      .navigationTitle(CoreL10n.tabGeneratorTitle)
      .navigationBarTitleDisplayMode(Device.is(.pad, .mac, .vision) ? .inline : .automatic)
      .reportPageAppearance(.passwordGenerator)
      .onAppear {
        viewModel.forcedRefresh()
      }
      .scrollContentBackgroundStyle(.alternate)
  }

  @ViewBuilder
  var trailingView: some View {
    switch viewModel.mode {
    case let .standalone(action):
      Button(
        action: {
          action(.showHistory)
        },
        label: {
          Image.ds.historyBackup.outlined
            .resizable()
            .contentShape(Rectangle())
            .frame(width: 24, height: 24)
            .fiberAccessibilityLabel(Text(CoreL10n.generatedPasswordListTitle))
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
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      Section {
        PasswordGeneratorSliderView(viewModel: viewModel)
      } header: {
        Group {
          Text(CoreL10n.kwPadExtensionGeneratorLength.uppercased())
            + Text(": \(viewModel.preferences.length)")
        }.foregroundStyle(Color.ds.text.neutral.quiet)
      }
      .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
      .listRowSeparator(.hidden)
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      Section {
        PasswordGeneratorViewOptions(preferences: $viewModel.preferences)
          .font(.body)
      } header: {
        Text(CoreL10n.kwPadExtensionOptions.uppercased())
          .foregroundStyle(Color.ds.text.neutral.quiet)
      }
      .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
      .listRowSeparator(.hidden)
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
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
        Button(CoreL10n.passwordGeneratorCopyButton, action: viewModel.performMainAction)
          .actionSheet(item: $viewModel.pendingSaveAsCredentialPassword) { password in
            makeSavePasswordActionSheet {
              action(.createCredential(password: password))
            }
          }
      case .selection:
        Button(CoreL10n.passwordGeneratorUseButton) {
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
      title: Text(CoreL10n.dwmOnboardingCardPWGTabEmailCopied).foregroundStyle(.green),
      message: Text(CoreL10n.savePasswordMessageNewpassword),
      buttons: [
        .default(Text(CoreL10n.kwSave), action: action),
        .cancel(Text(CoreL10n.kwNotSave)),
      ])

  }
}

struct PasswordGeneratorForm<Content: View>: View {

  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    if Device.is(.pad, .mac, .vision) {
      Form(content: content)
        .scrollContentBackground(.hidden)
        .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    } else {
      List(content: content)
        .listStyle(.ds.insetGrouped)
    }

  }
}

extension List {
  @ViewBuilder
  fileprivate func generatorListStyle() -> some View {
    if Device.is(.pad, .mac, .vision) {
      self.listStyle(.ds.plain)
    } else {
      self.listStyle(.ds.insetGrouped)
    }
  }
}

#Preview {
  PasswordGeneratorView(viewModel: PasswordGeneratorViewModel.mock)
    .navigationBarTitleDisplayMode(.inline)
}

extension GeneratedPassword: Identifiable {}
