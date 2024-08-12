import CoreLocalization
import CoreSession
import DashTypes
import DesignSystem
import NotificationKit
import SwiftTreats
import SwiftUI
import UIDelight

struct MainSettingsView: View {
  enum FullScreenItem: String, Identifiable {
    var id: String {
      return rawValue
    }
    case rateApp
    case deviceRegistration
  }

  @Environment(\.dismiss)
  private var dismiss

  @StateObject
  var viewModel: MainSettingsViewModel

  @State
  private var isPresentingRatingView = false

  @State
  private var presentedItem: Bool = false

  init(viewModel: @escaping @autoclosure () -> MainSettingsViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    List {
      SettingsStatusSection(model: viewModel.settingsStatusSectionViewModelFactory.make())

      Section {
        NavigationLink(value: SettingsSubSection.accountSummary) {
          Text(L10n.Localizable.accountSummaryTitle)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }

        NavigationLink(value: SettingsSubSection.general) {
          Text(L10n.Localizable.kwGeneral)
            .foregroundColor(.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }

        NavigationLink(value: SettingsSubSection.security) {
          Text(L10n.Localizable.kwSecurity)
            .foregroundColor(.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }

        NavigationLink(value: SettingsSubSection.helpCenter) {
          Text(L10n.Localizable.helpCenterTitle)
            .foregroundColor(.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }
      }

      Section {
        Button(
          action: { presentedItem = true },
          label: {
            Text(L10n.Localizable.Mpless.D2d.trustedNavigationTitle)
              .foregroundColor(.ds.text.neutral.standard)
              .textStyle(.body.standard.regular)
          }
        )
      }

      Section {
        Button(
          action: { viewModel.inviteFriends() },
          label: {
            Text(L10n.Localizable.kwInviteFriends)
              .foregroundColor(.ds.text.neutral.standard)
              .textStyle(.body.standard.regular)
          }
        )
        .activitySheet($viewModel.activityItem)

        Button(
          action: {
            isPresentingRatingView = true
          },
          label: {
            Text(L10n.Localizable.kwRateDashlane)
              .foregroundColor(.ds.text.neutral.standard)
              .textStyle(.body.standard.regular)
          })

        if viewModel.shouldDisplayLabs {
          NavigationLink(value: SettingsSubSection.labs) {
            Text(L10n.Localizable.internalDashlaneLabsSettingsButton)
              .foregroundColor(.ds.text.neutral.standard)
              .textStyle(.body.standard.regular)
          }
        }
      } footer: {
        informationFooter(display: Device.isMac)
      }

      if !Device.isMac {
        Section {
          Button(
            action: { viewModel.lock() },
            label: {
              Text(L10n.Localizable.kwLockNow)
                .foregroundColor(.ds.text.neutral.standard)
                .textStyle(.body.standard.regular)
            }
          )
        } footer: {
          informationFooter(display: !Device.isMac)
        }
      }
    }
    .listAppearance(.insetGrouped)
    .navigationBarTitleDisplayMode(Device.isIpadOrMac ? .inline : .large)
    .navigationTitle(CoreLocalization.L10n.Core.kwSettings)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        toolbarItemContent
      }
    }
    .navigationViewStyle(.stack)
    .overFullScreen(isPresented: $isPresentingRatingView) {
      RateAppView(
        viewModel: .init(
          login: viewModel.login,
          sender: .settings,
          userSettings: viewModel.userSettings))
    }
    .fullScreenCover(isPresented: $presentedItem) {
      AddNewDeviceView(model: viewModel.makeAddNewDeviceViewModel())
    }
    .reportPageAppearance(.settings)
    .foregroundColor(.ds.text.neutral.quiet)
  }

  @ViewBuilder
  private func informationFooter(display: Bool) -> some View {
    if display {
      Text("\(viewModel.session.configuration.login.email)\n\(footerVersionBuild)")
        .textStyle(.body.helper.regular)
    }
  }

  @ViewBuilder
  private var toolbarItemContent: some View {
    if Device.isIpadOrMac {
      Button(CoreLocalization.L10n.Core.kwDoneButton, action: dismiss.callAsFunction)
    }
  }

  private var footerVersionBuild: String {
    let base = "Dashlane v\(Application.version())"
    guard let information = Application.versionBuildOriginInformation() else {
      return base
    }
    return "\(base) - \(information)"
  }
}

struct MainSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      MainSettingsView(viewModel: MainSettingsViewModel.mock())
    }
  }
}
