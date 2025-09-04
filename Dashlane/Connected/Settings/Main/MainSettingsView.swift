import CoreLocalization
import CoreSession
import CoreTypes
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

  @Environment(\.accessControl)
  var accessControl

  init(viewModel: @escaping @autoclosure () -> MainSettingsViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    List {
      SettingsStatusSection(model: viewModel.settingsStatusSectionViewModelFactory.make())
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      Section {
        NavigationLink(value: SettingsSubSection.accountSummary) {
          Text(L10n.Localizable.accountSummaryTitle)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }

        NavigationLink(value: SettingsSubSection.general) {
          Text(L10n.Localizable.kwGeneral)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }

        NavigationLink(value: SettingsSubSection.security) {
          Text(L10n.Localizable.kwSecurity)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }

        NavigationLink(value: SettingsSubSection.helpCenter) {
          Text(L10n.Localizable.helpCenterTitle)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      if viewModel.canShowNewDevice {
        Section {
          Button(
            action: {
              accessControl.requestAccess(for: .addNewDevice) { success in
                if success {
                  presentedItem = true
                }
              }
            },
            label: {
              Text(L10n.Localizable.Mpless.D2d.trustedNavigationTitle)
                .foregroundStyle(Color.ds.text.neutral.standard)
                .textStyle(.body.standard.regular)
            }
          )
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }

      Section {
        Button(
          action: { viewModel.inviteFriends() },
          label: {
            Text(L10n.Localizable.kwInviteFriends)
              .foregroundStyle(Color.ds.text.neutral.standard)
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
              .foregroundStyle(Color.ds.text.neutral.standard)
              .textStyle(.body.standard.regular)
          })
      } footer: {
        informationFooter(display: Device.is(.mac))
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      if !Device.is(.mac) {
        Section {
          Button(
            action: { viewModel.lock() },
            label: {
              Text(L10n.Localizable.kwLockNow)
                .foregroundStyle(Color.ds.text.neutral.standard)
                .textStyle(.body.standard.regular)
            }
          )
        } footer: {
          informationFooter(display: !Device.is(.mac))
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }
    }
    .listStyle(.ds.insetGrouped)
    .navigationBarTitleDisplayMode(Device.is(.pad, .mac, .vision) ? .inline : .large)
    .navigationTitle(CoreL10n.kwSettings)
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
    .foregroundStyle(Color.ds.text.neutral.quiet)
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
    if Device.is(.pad, .mac, .vision) {
      Button(CoreL10n.kwDoneButton, action: dismiss.callAsFunction)
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
