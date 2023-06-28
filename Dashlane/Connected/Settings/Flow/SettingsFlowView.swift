import SwiftUI
import UIDelight
import ImportKit
import DesignSystem

struct SettingsFlowView: TabFlow {

        let tag: Int = 4
    let id: UUID = .init()
    let title: String = L10n.Localizable.tabSettingsTitle
    let tabBarImage = NavigationImageSet(image: .ds.settings.outlined,
                                         selectedImage: .ds.settings.filled)

    @StateObject
    var viewModel: SettingsFlowViewModel

    init(viewModel: @autoclosure  @escaping @MainActor () -> SettingsFlowViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
                NavigationStack(path: $viewModel.subSectionsPath.animation(.default)) {
            MainSettingsView(viewModel: viewModel.makeMainViewModel())
                .navigationDestination(for: SettingsSubSection.self) { step in
                    switch step {
                    case .security:
                        SecuritySettingsView(viewModel: viewModel.securitySettingsViewModelFactory.make())
                    case .general:
                        GeneralSettingsView(viewModel: viewModel.generalSettingsViewModelFactory.make())
                    case .helpCenter:
                        HelpCenterSettingsView(viewModel: viewModel.helpCenterSettingsViewModelFactory.make())
                    case .labs:
                        LabsSettingsView(viewModel: viewModel.makeLabsViewModel())
                    }
                }
        }
        .tint(.ds.text.brand.standard)
    }
}

struct SettingsFlowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFlowView(viewModel: .mock)
    }
}
