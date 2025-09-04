import DesignSystem
import SecurityDashboard
import SwiftTreats
import SwiftUI
import UIDelight

struct NotificationsListView: View {

  enum Step {
    case root
    case section(NotificationDataSection)
    case unresolvedAlert(TrayAlertContainer)
  }

  @StateObject
  var model: NotificationsListViewModel

  @State private var steps: [Step] = [.root]

  init(model: @autoclosure @escaping () -> NotificationsListViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $steps) { step in
      switch step {
      case .root:
        listContent
          .onReceive(model.notificationCategoryDeeplink.receive(on: DispatchQueue.main)) {
            category in
            guard let section = self.model.dataSection(for: category) else {
              return
            }
            self.steps.append(.section(section))
          }
      case let .section(section):
        NotificationsCategoryListView(model: model.categoryListViewModel(section: section))

      case let .unresolvedAlert(alert):
        UnresolvedAlertView(
          viewModel: model.unresolvedAlertViewModelFactory.make(),
          trayAlert: alert.alert
        )
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
      }
    }
    .tint(.ds.text.neutral.standard)
    .onReceive(model.deepLinkPublisher, perform: handle)
  }

  func handle(_ deepLink: DeepLink) {
    switch deepLink {
    case .unresolvedAlert(let alert):
      steps.append(.unresolvedAlert(.init(alert)))
    default: break

    }
  }

  var listContent: some View {
    Group {
      if model.sections.isEmpty {
        placeholder
      } else {
        list
      }
    }
    .navigationBarTitleDisplayMode(Device.is(.pad, .mac, .vision) ? .inline : .large)
    .navigationTitle(L10n.Localizable.actionItemsCenterTitle)
    .reportPageAppearance(.notificationHome)
  }

  var list: some View {
    List {
      ForEach(model.sections) { section in
        NotificationSectionView(model: model.sectionViewModel(section: section)) {
          self.steps.append(.section(section))
        }
      }
    }
    .listStyle(.ds.insetGrouped)
  }

  var placeholder: some View {
    VStack {
      Spacer()

      VStack(spacing: 24) {
        DS.ExpressiveIcon(.ds.notification.outlined)
          .style(mood: .neutral)
          .controlSize(.large)

        Text(L10n.Localizable.actionItemCenterEmptyMessage)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.horizontal, 40)

      Spacer()
    }
  }
}

struct NotificationsListView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationsListView(model: NotificationsListViewModel.mock)
  }
}
