import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight

struct NotificationsListView: View {

  enum Step {
    case root
    case section(NotificationDataSection)
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
      }
    }
    .accentColor(.ds.text.neutral.standard)
  }

  var listContent: some View {
    Group {
      if model.sections.isEmpty {
        placeholder
      } else {
        list
      }
    }
    .navigationBarTitleDisplayMode(Device.isIpadOrMac ? .inline : .large)
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
    .listAppearance(.insetGrouped)
  }

  var placeholder: some View {
    VStack(spacing: 35) {
      Image(asset: FiberAsset.iconNotificationLarge)
        .foregroundColor(.ds.text.neutral.quiet)
      Text(L10n.Localizable.actionItemCenterEmptyMessage)
        .foregroundColor(.ds.text.neutral.standard)
      Spacer()
    }
    .padding(.top, 100)
    .padding(.horizontal, 16)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }
}

struct NotificationsListView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationsListView(model: NotificationsListViewModel.mock)
  }
}
