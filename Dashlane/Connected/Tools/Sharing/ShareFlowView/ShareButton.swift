import SwiftUI

struct ShareButton<Label: View>: View {
    let model: ShareButtonViewModel

    @ViewBuilder
    let label: Label

    @State
    var showDisabledAlert: Bool = false

    @State
    var showFlow: Bool = false

    var body: some View {
        Button {
            if model.deactivationReason != nil {
                showDisabledAlert = true
            } else {
                showFlow = true
            }
        } label: {
            label
        }
        .accessibilityLabel(L10n.Localizable.kwShareItem)
        .alert(isPresented: $showDisabledAlert) {
            Alert(model.deactivationReason ?? .b2bSharingDisabled)
        }
        .sheet(isPresented: $showFlow) {
            ShareFlowView(model: model.makeShareFlowViewModel())
        }
    }
}

struct ShareButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ShareButton(model: .mock()) {
                Text("Full Flow Button")
            }
            ShareButton(model: .mock(items: [PersonalDataMock.Credentials.amazon])) {
                Text("Share one item")
            }
        }

    }
}
