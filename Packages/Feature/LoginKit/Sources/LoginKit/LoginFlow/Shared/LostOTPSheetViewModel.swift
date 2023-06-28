import Foundation
import CoreSession

public enum AlertStep: String, Identifiable {
    case sendRecoveryKeyBySMS
    case confirmationSentRecoveryKeyBySMS

    public var id: String { rawValue }
}

public class LostOTPSheetViewModel: ObservableObject {

    private let recover2faService: Recover2FAWebService

    @Published
    public var alertStep: AlertStep?

    #if canImport(UIKit)
    @Published
    var textfieldAlertItem: RecoveryTextfieldAlertModifier.Item?
    #endif

    @Published
    public var recoverConfirmationError: Recover2FAError? {
        didSet {
            if recoverConfirmationError != nil {
                alertStep = .confirmationSentRecoveryKeyBySMS
            } else {
                alertStep = nil
            }
        }
    }

    public init(recover2faService: Recover2FAWebService) {
        self.recover2faService = recover2faService
    }

    #if canImport(UIKit)
    public func recoverCodes() {
        recover2faService.recoverCodes { result in
            switch result {
            case .success:
                self.textfieldAlertItem = .smsCode
            case let .failure(error):
                self.recoverConfirmationError = error
            }
        }
    }
    #endif
}
