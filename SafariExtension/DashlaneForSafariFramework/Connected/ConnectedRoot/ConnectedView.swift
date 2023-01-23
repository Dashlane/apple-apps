import SwiftUI

struct NavigationWrapperView: Identifiable {
    let id = UUID()
    let content: AnyView
}

class PopoverNavigationWrapper: ObservableObject, PopoverNavigator {

    @Published
    var views = [NavigationWrapperView]()
    
    func push<V: View>(_ view: V) {
        views.append(.init(content: view
                            .environment(\.popoverNavigator, self)
                            .eraseToAnyView()))
    }
    
    func popLast() {
        _ = views.popLast()
    }
    
    func popToRoot() {
        while !views.isEmpty {
            _ = views.popLast()
        }
    }
}

struct ConnectedView: View {
    
    @ObservedObject
    var viewModel: ConnectedViewModel
    
    @StateObject
    private var navigator = PopoverNavigationWrapper()
    
    var body: some View {
        StackNavigationView(subviews: $navigator.views) {
            VStack(spacing: 0) {
                MainTabView(initial: $viewModel.selectedTab, tabs: viewModel.allTabs)
                VStack(spacing: 8) {
                    Divider()
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigator(navigator)
        .onReceive(viewModel.appServices.popoverOpeningService.publisher, perform: { popoverOpening in
            guard popoverOpening == .afterTimeLimit else { return }
            navigator.popToRoot()
        })
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.selectedTab {
        case let .vault(viewModel):
            VaultView(viewModel: viewModel)
        case let .autofill(viewModelAutofill):
            AutofillTabView(viewModel: viewModelAutofill)
        case let .passwordGenerator(viewModel):
            PasswordGeneratorTabView(viewModel: viewModel)
        case let .other(viewModel):
            MoreTabView(viewModel: viewModel)
        }
    }
}
