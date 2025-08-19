import Combine
import CoreLocalization
import CorePersonalData
import DesignSystem
import SecurityDashboard
import SwiftUI
import UIComponents
import UIDelight

struct DarkWebMonitoringBreachListView: View {

  @StateObject var viewModel: DarkWebMonitoringBreachListViewModel

  @State private var toBeDeleted: IndexSet?
  @State private var showConfirmAlert: Bool = false

  @State var selectedListType: Int = 0

  private var filteredBreaches: [DWMSimplifiedBreach] {
    return self.viewModel.breaches.filter {
      BreachListType(rawValue: selectedListType)?.storedBreachStatuses.contains($0.status) ?? false
    }
  }

  init(
    viewModel: @autoclosure @escaping () -> DarkWebMonitoringBreachListViewModel,
    selectedListType: Int = 0
  ) {
    _viewModel = .init(wrappedValue: viewModel())
    self.selectedListType = selectedListType
  }

  var body: some View {
    Group {
      Section {
        Text(L10n.Localizable.darkWebMonitoringListViewSectionHeaderTitle)
          .textStyle(.title.section.medium)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .listRowBackground(Color.ds.background.alternate)
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
      }
      .listSectionSpacing(0)

      listView
        .confirmationDialog(
          L10n.Localizable.dwmDetailViewDeleteConfirmTitle,
          isPresented: $showConfirmAlert,
          actions: {
            Button(CoreL10n.kwDelete) {
              deleteItems()
              toBeDeleted = nil
            }
          }
        )
        .reportPageAppearance(.toolsDarkWebMonitoringList)
        .onAppear {
          viewModel.reportPendingBreaches()
        }
    }
    .animation(.easeInOut, value: selectedListType)

  }

  @ViewBuilder
  private var listView: some View {
    Section {
      Picker(selection: $selectedListType) {
        pendingSegment
        solvedSegment
      } label: {
        EmptyView()
      }
      .pickerStyle(.segmented)
      .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
      .listRowBackground(Color.ds.background.alternate)
      .padding(.bottom, 16)
      .tint(.ds.text.brand.standard)
    }
    .listSectionSpacing(0)

    if !filteredBreaches.isEmpty {
      ForEach(filteredBreaches, id: \.self) { breach in
        DarkWebMonitoringBreachView(model: self.viewModel.makeRowViewModel(breach))
          .onTapGesture { self.viewModel.actionPublisher?.send(.showDetails(breach)) }
      }.onDelete(perform: { indexSet in
        toBeDeleted = indexSet
        showConfirmAlert.toggle()
      })

    } else {
      emptyListView
    }
  }

  private var pendingSegment: some View {
    Group {
      Text(L10n.Localizable.dataleakEmailStatusPending)
        + Text("(\(viewModel.pendingBreachesCount))")
    }
    .tag(BreachListType.pending.rawValue)
  }

  private var solvedSegment: some View {
    Group {
      Text(L10n.Localizable.dwmAlertSolvedTitle) + Text("(\(viewModel.solvedBreachesCount))")
    }
    .tag(BreachListType.solved.rawValue)
  }

  private var segmentedControl: some View {
    Picker("", selection: $selectedListType) {
      ForEach(BreachListType.allCases, id: \.self) {
        Text($0.title)
      }
    }.pickerStyle(SegmentedPickerStyle())
  }

  @ViewBuilder
  private var emptyListView: some View {
    let selectedListType = BreachListType(rawValue: selectedListType)!

    VStack(alignment: .center, spacing: 16) {
      let image: Image =
        switch selectedListType {
        case .pending:
          .ds.feature.darkWebMonitoring.outlined
        case .solved:
          .ds.healthPositive.outlined
        }
      DS.ExpressiveIcon(image)
        .style(mood: selectedListType == .pending ? .neutral : .positive, intensity: .quiet)
        .controlSize(.extraLarge)

      let content: String =
        switch selectedListType {
        case .pending:
          L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationNoBreachesSubtitle
        case .solved:
          L10n.Localizable.breachViewSolvedEmptyViewTitle
        }

      VStack(spacing: 2) {
        Text(content)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .textStyle(.body.standard.regular)
          .multilineTextAlignment(.center)

        if selectedListType == .solved {
          Button(
            action: { self.selectedListType = BreachListType.pending.rawValue },
            label: {
              Text(L10n.Localizable.breachViewSolvedEmptyViewButton)
            }
          )
          .buttonStyle(.designSystem(.titleOnly))
          .style(intensity: .supershy)
          .controlSize(.mini)
        }
      }
    }
    .padding(.top, 16)
    .id(selectedListType)
    .frame(maxWidth: .infinity)
    .listRowBackground(Color.ds.background.alternate)
  }

  @ViewBuilder
  private var premiumView: some View {
    DarkWebMonitoringPremiumListView(
      isDwmEnabled: viewModel.isMonitoringAvailable, actionPublisher: .init())
  }

  private func deleteItems() {
    guard let indexSet = toBeDeleted else { return }
    let items = indexSet.map { viewModel.breaches[$0] }
    items.forEach { viewModel.delete($0) }
  }
}

#Preview {
  List {
    DarkWebMonitoringBreachListView(viewModel: .mock(isMonitoringAvailable: true))
  }.listStyle(.ds.insetGrouped)
}

#Preview {
  List {
    DarkWebMonitoringBreachListView(
      viewModel: .mock(
        breaches: [
          .mock
        ], isMonitoringAvailable: true))
  }.listStyle(.ds.insetGrouped)
}

#Preview {
  List {
    DarkWebMonitoringBreachListView(
      viewModel: .mock(
        breaches: [
          .mock
        ], isMonitoringAvailable: true), selectedListType: 1)
  }.listStyle(.ds.insetGrouped)
}

#Preview {
  List {
    DarkWebMonitoringBreachListView(viewModel: .mock(breaches: [], isMonitoringAvailable: false))
  }.listStyle(.ds.insetGrouped)
}

extension Credential {
  fileprivate init(url: PersonalDataURL) {
    self.init()
    self.url = url
  }
}
