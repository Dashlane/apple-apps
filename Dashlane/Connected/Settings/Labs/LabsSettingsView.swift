import SwiftUI
import DesignSystem

struct LabsSettingsView: View {

    @StateObject
    var model: LabsSettingsViewModel

    public init(viewModel: @autoclosure @escaping () -> LabsSettingsViewModel) {
        self._model = .init(wrappedValue: viewModel())
    }

    var body: some View {
        VStack {
            Infobox(title: L10n.Localizable.internalDashlaneLabsInfoText, buttons: { Button(action: { model.goToFeedbackForm() }, title: L10n.Localizable.internalDashlaneLabsInfoFeedbackCta)})

            List {
                ForEach(model.featureFlips) { flip in
                    HStack {
                        Text(flip.name)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        if flip.isOn {
                            Spacer()
                            Image.ds.checkmark.outlined
                                .foregroundColor(.ds.text.brand.standard)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle(L10n.Localizable.internalDashlaneLabsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
    }
}

struct LabsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LabsSettingsViewModel.mock
        LabsSettingsView(viewModel: viewModel)
    }
}
