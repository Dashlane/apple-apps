import SwiftUI
import CorePersonalData
import Combine
import SecurityDashboard
import UIDelight
import UIComponents

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

    init(viewModel: @autoclosure @escaping () -> DarkWebMonitoringBreachListViewModel, selectedListType: Int = 0) {
        _viewModel = .init(wrappedValue: viewModel())
        self.selectedListType = selectedListType
    }

    var body: some View {
        ZStack {
            Color.ds.background.default.edgesIgnoringSafeArea(.all)
            if viewModel.isMonitoringAvailable {
                if viewModel.shouldShowList {
                    listView
                } else {
                    EmptyView()
                }
            } else {
                premiumView
            }
        }.alert(isPresented: $showConfirmAlert, content: { alertView })
        .reportPageAppearance(.toolsDarkWebMonitoringList)
        .onAppear {
            viewModel.reportPendingBreaches()
        }

    }

    @State
    private var listHeight: CGFloat = 0

    @ViewBuilder
    private var listView: some View {
        VStack(spacing: 0) {
            CustomSegmentedControl(selectedIndex: $selectedListType, options: [
                pendingSegment,
                solvedSegment
            ]).background(.ds.background.default)

            if !filteredBreaches.isEmpty {
                List {
                    ForEach(filteredBreaches, id: \.self) { breach in
                        DarkWebMonitoringBreachView(model: self.viewModel.makeRowViewModel(breach))
                            .onTapGesture { self.viewModel.actionPublisher?.send(.showDetails(breach)) }
                    }.onDelete(perform: { indexSet in
                        toBeDeleted = indexSet
                        showConfirmAlert.toggle()
                    })
                }.listStyle(GroupedListStyle())
            } else {
                emptyListView
            }
        }.animation(.easeInOut, value: selectedListType)
        .frame(maxHeight: .infinity)
    }

    private var pendingSegment: CustomSegment {
        CustomSegment(title: L10n.Localizable.dataleakEmailStatusPending,
                      segmentTag: SegmentTag(tag: viewModel.pendingBreachesCount, type: .full))
    }

    private var solvedSegment: CustomSegment {
        CustomSegment(title: L10n.Localizable.dwmAlertSolvedTitle,
                      segmentTag: SegmentTag(tag: viewModel.solvedBreachesCount, type: .outline))
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

        let image: ImageAsset.Image = {
            switch selectedListType {
                case .pending: return FiberAsset.thumbsAllGood.image
                case .solved: return FiberAsset.emptyViewSolved.image
            }
        }()

        let content: String = {
            switch selectedListType {
                case .pending: return L10n.Localizable.darkWebMonitoringOnboardingEmailConfirmationNoBreachesSubtitle
                case .solved: return L10n.Localizable.breachViewSolvedEmptyViewTitle
            }
        }()

        ScrollView {
            VStack(alignment: .center) {
                Image(uiImage: image).padding(.bottom, 35).padding(.top, 65)
                Text(content)
                    .foregroundColor(Color(asset: FiberAsset.neutralText))
                    .font(.body).padding(.bottom, 32)
                    .multilineTextAlignment(.center)

                Button(action: { self.selectedListType = BreachListType.pending.rawValue }, label: {
                    Text(L10n.Localizable.breachViewSolvedEmptyViewButton)
                })
                .buttonStyle(ColoredButtonStyle())
                .hidden(selectedListType != .solved)

                Spacer()
            }
            .id(selectedListType)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var premiumView: some View {
        DarkWebMonitoringPremiumListView(isDwmEnabled: viewModel.isMonitoringAvailable, actionPublisher: .init())
    }

    private var alertView: Alert {
        Alert(title: Text(L10n.Localizable.dwmDetailViewDeleteConfirmTitle),
              primaryButton: Alert.Button.default(Text(L10n.Localizable.kwDelete), action: {
                deleteItems()
                toBeDeleted = nil
              }),
              secondaryButton: Alert.Button.cancel()
        )
    }

    private func deleteItems() {
        guard let indexSet = toBeDeleted else { return }
        let items = indexSet.map { viewModel.breaches[$0] }
        items.forEach { viewModel.delete($0) }
    }
}

struct DarkWebMonitoringBreachListView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            DarkWebMonitoringBreachListView(viewModel: .mock(isMonitoringAvailable: true))
            DarkWebMonitoringBreachListView(viewModel: .mock(breaches: [], isMonitoringAvailable: true))
            DarkWebMonitoringBreachListView(viewModel: .mock(breaches: [], isMonitoringAvailable: true), selectedListType: 1)
            DarkWebMonitoringBreachListView(viewModel: .mock(breaches: [], isMonitoringAvailable: false))

        }
    }
}

private extension Credential {
    init(url: PersonalDataURL) {
        self.init()
        self.url = url
    }
}
