import SwiftUI
import SwiftTreats
import UIDelight

struct NotificationsListView: View {

    @StateObject
    var model: NotificationsListViewModel

    init(model: @autoclosure @escaping () -> NotificationsListViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        StepBasedNavigationView(steps: $model.steps) { step in
            switch step {
            case .list:
                listContent

            case let .category(model):
                NotificationsCategoryListView(model: model)
            }
        }
        .navigationViewStyle(.stack)
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
                NotificationSectionView(model: model.sectionViewModel(section: section))
            }
        }
        .listStyle(.insetGrouped)
    }

    var placeholder: some View {
        VStack(spacing: 35) {
            Image(asset: FiberAsset.iconNotificationLarge)
                .foregroundColor(Color(asset: FiberAsset.emptyStateIconTintColor))
            Text(L10n.Localizable.actionItemCenterEmptyMessage)
                .foregroundColor(Color(asset: FiberAsset.neutralText))
            Spacer()
        }
        .padding(.top, 100)
        .padding(.horizontal, 16)
    }
}

struct NotificationsListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsListView(model: NotificationsListViewModel.mock)
    }
}
