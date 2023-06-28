import Foundation
import CoreKeychain
import DashTypes

class PinCodeSetupViewModel: ObservableObject {

    @Published
    var choosePinCode: Bool = false

    private let login: Login
    let completion: (String) -> Void

    init(login: Login, completion: @escaping (String) -> Void) {
        self.login = login
        self.completion = completion
    }

    func makePinCodeViewModel() -> PinCodeSelectionViewModel {
        PinCodeSelectionViewModel { [weak self] pin in
            guard let self else { return }
            self.choosePinCode = false
            guard let pin else { return }
            self.enablePincode(pin)
        }
    }

    func enablePincode(_ code: String) {
        completion(code)
    }
}
