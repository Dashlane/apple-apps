import Foundation
import SwiftUI
import UIComponents
import CoreLocalization

public struct PinCodeSelection: View {

    @StateObject
    var model: PinCodeSelectionViewModel

    @Environment(\.dismiss)
    private var dismiss

    public init(model: @autoclosure @escaping () -> PinCodeSelectionViewModel) {
        _model = .init(wrappedValue: model())
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(model.current.prompt)
                .id(model.current.prompt)
            PinCodeView(pinCode: $model.pincode, attempt: model.failedAttempts) {
                self.model.cancel()
                self.dismiss()
            }
        }
        .animation(.default, value: model.current.prompt)
        .backgroundColorIgnoringSafeArea(Color.ds.background.alternate)
    }
}

extension PinCodeSelectionViewModel.Step {
    var prompt: String {
        switch self {
        case .verify:
            return L10n.Core.kwEnterYourPinCode
        case .select:
            return L10n.Core.kwChoosePinCode
        case .confirm:
            return L10n.Core.kwConfirmPinCode
        }
    }
}

struct PinCodeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PinCodeSelection(model: PinCodeSelectionViewModel(currentPin: "0000", completion: { _ in
        }))
    }
}
