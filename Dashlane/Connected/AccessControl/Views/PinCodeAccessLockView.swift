import SwiftUI
import UIComponents
import LoginKit

struct PinCodeAccessLockView: View {
    let title: String

    @ObservedObject
    var model: PinCodeAccessLockViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            PinCodeView(pinCode: $model.enteredPincode, attempt: model.attempts, cancelAction: model.cancel).padding()
        }
        .frame(height: UIScreen.main.bounds.height/1.75)
        .padding(.top, 20)
        .modifier(AlertStyle())
    }

}

class PinCodeAccessLockViewModel: ObservableObject {
    @Published
    var enteredPincode: String = "" {
        didSet {
            if enteredPincode.count == 4 {
                validate()
            }
        }
    }

    @Published
    var attempts: Int = 0

    let validation: (String) -> Void
    let dismiss: () -> Void

    init(validation: @escaping (String) -> Void,
         dismiss: @escaping () -> Void) {
        self.validation = validation
        self.dismiss = dismiss
    }

    func cancel() {
       dismiss()
    }

    func validate() {
        validation(enteredPincode)
        attempts += 1
    }
}
