import Combine
import DesignSystem
import SwiftUI
import UIDelight

enum PairingStatusAnnouncementAction {
  case installApplication
  case configureApplication
}

struct PairingStatusAnnouncement: View {
  @Environment(\.scenePhase) var scenePhase

  @StateObject
  var viewModel: PairingStatusAnnouncementViewModel
  let refreshPairingAnnouncement: AnyPublisher<Void, Never>
  let action: (PairingStatusAnnouncementAction) -> Void

  init(
    viewModel: @autoclosure @escaping () -> PairingStatusAnnouncementViewModel = {
      PairingStatusAnnouncementViewModel()
    }(),
    refreshPairingAnnouncement: AnyPublisher<Void, Never>,
    action: @escaping (PairingStatusAnnouncementAction) -> Void
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.refreshPairingAnnouncement = refreshPairingAnnouncement
    self.action = action
  }

  var body: some View {
    Group {
      switch viewModel.status {
      case .notInstalled:
        notInstalledLabel
      case .installedButNotPaired:
        notPairedLabel
      case .installedButAccountNotCreated:
        noAccountLabel
      }
    }
    .padding(.horizontal, 16)
    .onChange(of: scenePhase) { phase in
      guard phase == .active else { return }
      self.viewModel.refreshStatus()
    }
    .onReceive(refreshPairingAnnouncement) {
      self.viewModel.refreshStatus()
    }
  }

  var notInstalledLabel: some View {
    Button(
      action: { action(.installApplication) },
      label: {
        HStack {
          Text(L10n.Localizable.backupYourAccountsAnnouncementTitle)
          Spacer()
          Image.ds.arrowRight.outlined
        }
        .font(.body.weight(.medium))
        .foregroundColor(.ds.text.brand.standard)
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(.ds.container.expressive.brand.quiet.idle)
        .cornerRadius(8)
      })
  }

  var notPairedLabel: some View {
    Infobox(
      L10n.Localizable.backupNotPairedTitle,
      description: L10n.Localizable.backupNotPairedDescription
    ) {
      Button(L10n.Localizable.backupNotPairedFinishCta) {
        action(.configureApplication)
      }
    }
    .style(mood: .warning)
  }

  var noAccountLabel: some View {
    Infobox(
      L10n.Localizable.createYourAccountAnnouncementTitle,
      description: L10n.Localizable.createYourAccountAnnouncementMessage
    ) {
      Button(L10n.Localizable.backupNotPairedFinishCta) {
        action(.configureApplication)
      }
    }
    .style(mood: .warning)
  }
}

#Preview {
  VStack {
    PairingStatusAnnouncement(
      viewModel: .mockNotInstalled,
      refreshPairingAnnouncement: PassthroughSubject<Void, Never>().eraseToAnyPublisher(),
      action: { _ in }
    )
    PairingStatusAnnouncement(
      viewModel: .mockNotPaired,
      refreshPairingAnnouncement: PassthroughSubject<Void, Never>().eraseToAnyPublisher(),
      action: { _ in }
    )
  }
}
