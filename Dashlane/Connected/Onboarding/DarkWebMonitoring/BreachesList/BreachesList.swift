import SwiftUI
import CorePersonalData
import UIDelight

struct BreachesList<Model: BreachesListViewModelProtocol>: View {

    @ObservedObject
    var viewModel: Model

    init(viewModel: Model) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            Section(header: header) {
                if viewModel.pendingBreaches.isEmpty == false {
                    ForEach(self.viewModel.pendingBreaches, id: \.self) { breach in
                        BreachView(model: self.viewModel.makeRowViewModel(breach))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.viewModel.select(breach)
                        }
                    }.onDelete(perform: deleteItems)
                } else {
                    emptyListView
                }
            }.disableHeaderCapitalization()

                        Section(header: footer) { EmptyView() }.disableHeaderCapitalization()

            Section(header: securedSectionHeader) {
                ForEach(self.viewModel.securedItems, id: \.id) { credential in
                    BreachView(model: self.viewModel.makeRowViewModel(credential))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.viewModel.select(credential)
                    }
                }
            }
            .disableHeaderCapitalization()
            .hidden(self.viewModel.securedItems.isEmpty)
        }
        .onAppear {
            self.viewModel.logDisplay()
            self.viewModel.breachesViewed()
        }
        .listStyle(GroupedListStyle())
        .background(Color(asset: FiberAsset.appBackground))
        .navigationTitle(L10n.Localizable.dwmOnboardingFixBreachesMainTitle)
    }

    private var header: some View {
        HStack {
            Text(L10n.Localizable.dwmOnboardingFixBreachesMainDescription)
            .font(.body)
            .foregroundColor(Color(asset: FiberAsset.dwmDashGreen01))
            .padding(.top, 20)
            .padding(.bottom, 16)
            .padding(.horizontal, 20)
            Spacer()
        }
        .background(Color(asset: FiberAsset.appBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    private var securedSectionHeader: some View {
        Text(L10n.Localizable.dwmOnboardingFixBreachesMainInYourVault)
            .font(.body)
            .background(Color(asset: FiberAsset.appBackground))
    }

    private var footer: some View {
        HStack {
            Text(L10n.Localizable.dwmOnboardingFixBreachesMainSwipeToIgnoreNotice)
                .font(.footnote)
                .foregroundColor(Color(asset: FiberAsset.dwmDashGreen01))
                .padding(.bottom, 16)
                .padding(.horizontal, 20)
            Spacer()
        }
        .background(Color(asset: FiberAsset.appBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    private var emptyListView: some View {
        HStack {
            Text(L10n.Localizable.dwmOnboardingFixBreachesMainAllClear)
                .font(.headline)
                .foregroundColor(Color(asset: FiberAsset.buttonBackgroundIncreasedContrast))
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
            Spacer()
        }
        .background(Color(asset: FiberAsset.iconPlaceholderBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    private func deleteItems(at indexSet: IndexSet) {
        let items = indexSet.map { viewModel.pendingBreaches[$0] }
        items.forEach { viewModel.delete($0) }
    }
}

struct DWMBreachesList_Previews: PreviewProvider {

    static var breaches: [DWMSimplifiedBreach] {
        return [
            DWMSimplifiedBreach(breachId: "test1", url: PersonalDataURL(rawValue: "test1.com"), leakedPassword: "test", date: nil),
            DWMSimplifiedBreach(breachId: "test2", url: PersonalDataURL(rawValue: "test2.com"), leakedPassword: nil, date: nil)
        ]
    }

    class Model: BreachesListViewModelProtocol {
        var pendingBreaches: [DWMSimplifiedBreach]
        var securedItems: [Credential]

        init(breaches: [DWMSimplifiedBreach]) {
            self.pendingBreaches = breaches
            self.securedItems = [Credential(url: PersonalDataURL(rawValue: "_"))]
        }

        func makeRowViewModel(_ breach: DWMSimplifiedBreach) -> BreachViewModel {
            BreachViewModel.mock(for: breach)
        }

        func makeRowViewModel(_ credential: Credential) -> BreachViewModel {
            BreachViewModel.mock(for: credential)
        }

        func logDisplay() {}
        func breachesViewed() {}
        func select(_ breach: DWMSimplifiedBreach) {}
        func select(_ credential: Credential) {}
        func delete(_ item: DWMSimplifiedBreach) {}
    }

    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            BreachesList(viewModel: Model(breaches: breaches))
            BreachesList(viewModel: Model(breaches: [DWMSimplifiedBreach]()))
        }
    }
}

private extension Credential {
    init(url: PersonalDataURL) {
        self.init()
        self.url = url
    }
}
