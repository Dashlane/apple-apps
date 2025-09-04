import Combine
import CoreFeature
import CoreLocalization
import CorePasswords
import CorePersonalData
import CoreSettings
import CoreTypes
import DesignSystem
import IconLibrary
import Logger
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation
import VaultKit

public struct AddCredentialView: View {

  @StateObject
  var model: AddCredentialViewModel

  @FocusState private var isWebsiteFieldFocused

  @Environment(\.dismiss)
  private var dismiss

  @FeatureState(.prideColors)
  private var isPrideColorsEnabled: Bool

  public init(model: @autoclosure @escaping () -> AddCredentialViewModel) {
    _model = .init(wrappedValue: model())
  }

  public var body: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      switch step {
      case .root:
        list
          .navigationTitle(CoreL10n.kwadddatakwAuthentifiantIOS)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button(CoreL10n.kwSave) {
                Task {
                  await save()
                }
              }
            }
          }
          .onAppear {
            isWebsiteFieldFocused = true
          }
      case .passwordGenerator:
        PasswordGeneratorView(viewModel: model.makePasswordGeneratorViewModel())
      case .confirmation:
        AddCredentialConfirmationView(
          item: model.item,
          didFinish: model.didFinish
        )
      }

    }
    .reportPageAppearance(.autofillExplorePasswordsCreate)
  }

  @ViewBuilder
  var list: some View {
    List {
      content
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
        .environment(\.detailMode, .adding())
    }
    .listStyle(.ds.insetGrouped)
  }

  @ViewBuilder
  var content: some View {
    Group {
      Section(CoreL10n.addCredentialWebsiteSection) {
        website
      }
      if model.hasSpaceSelection {
        Section(CoreL10n.addCredentialWebsiteSpace) {
          spaceSelector
        }
      }
      Section(CoreL10n.addCredentialWebsiteLogin) {
        email
        password
      }
    }
  }

  @ViewBuilder
  var website: some View {
    DS.TextField(CoreL10n.KWAuthentifiantIOS.urlStringForUI, text: $model.item.editableURL)
      .focused($isWebsiteFieldFocused)
  }

  @ViewBuilder
  var spaceSelector: some View {
    HStack {
      UserSpaceIcon(space: model.selectedSpace, size: .normal)
        .equatable()
        .padding(4)
      Text(model.selectedSpace.teamName)
        .foregroundStyle(Color.ds.text.brand.standard)
        .font(.subheadline.weight(.regular))

      if model.spaceIsSwitchable {
        Spacer()

        Menu(
          content: {
            ForEach(model.availableUserSpaces) { space in
              Button {
                model.selectedSpace = space
              } label: {
                Text(space.teamName)
              }
            }
          },
          label: {
            Image.ds.action.more.outlined
          })
      }
    }
  }

  @ViewBuilder
  var email: some View {
    DS.TextField(
      model.loginIsMail ? CoreL10n.KWAuthentifiantIOS.email : CoreL10n.KWAuthentifiantIOS.login,
      placeholder: "\(CoreL10n.KWAuthentifiantIOS.email) / \(CoreL10n.KWAuthentifiantIOS.login)",
      text: $model.login,
      actions: {
        if !model.emails.isEmpty {
          DS.FieldAction.Menu(
            CoreL10n.detailItemViewAccessibilitySelectEmail,
            image: .ds.action.more.outlined
          ) {
            ForEach(model.emails) { email in
              Button(email.value) {
                model.login = email.value
              }
            }
          }
        }
      }
    )
    .textContentType(.emailAddress)
  }

  @ViewBuilder
  var password: some View {
    VStack(spacing: 4) {
      DS.TextField(
        CoreL10n.KWAuthentifiantIOS.password, text: $model.item.password,
        actions: {
          DS.FieldAction.Button(
            CoreL10n.kwPadExtensionGeneratorRefresh,
            image: .ds.action.refresh.outlined,
            action: model.refreshPassword
          )
        }
      )
      .secureInput()
      .textFieldRevealSecureValue(model.shouldReveal)
      .textFieldColorHighlightingMode(.password)

      passwordAccessory

      Button(CoreL10n.addCredentialGeneratorCTA) {
        model.steps.append(.passwordGenerator)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .supershy)
      .padding(.top)
    }
  }

  @ViewBuilder
  private var passwordAccessory: some View {
    TextInputPasswordStrengthFeedback(
      strength: model.passwordStrength, colorful: isPrideColorsEnabled
    )
    .animation(.default, value: model.passwordStrength)
  }

  private func save() async {
    model.prepareForSaving()
    await model.save()
    model.steps.append(.confirmation)
  }
}

#Preview {
  AddCredentialView(
    model: .mock(
      existingItems: [PersonalDataMock.Emails.personal, PersonalDataMock.Emails.work],
      hasBusinessTeam: true))
}
