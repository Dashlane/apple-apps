import Foundation
import CoreUserTracking
import CoreSession
import CoreLocalization
import UIComponents

@MainActor
public class DeviceToDeviceOTPLoginViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum CompletionType {
        case success(isBackupCode: Bool)
        case error(Error)
        case cancel
    }

    @Published
    var state: ProgressionState = .inProgress(L10n.Core.deviceToDevicePushInProgress)

    @Published
    var otpValue: String = "" {
        didSet {
            isTokenError = false
        }
    }

    @Published
    var showPushView = false

    @Published
    var isTokenError = false

    @Published
    var inProgress = false

    var canValidate: Bool {
        otpValue.count == 6
    }

    let validator: ThirdPartyOTPDeviceRegistrationValidator
    let activityReporter: ActivityReporterProtocol
    let recover2faWebService: Recover2FAWebService
    let lostOTPSheetViewModel: LostOTPSheetViewModel
    let pushType: PushType?
    let completion: (DeviceToDeviceOTPLoginViewModel.CompletionType) -> Void

    public init(validator: ThirdPartyOTPDeviceRegistrationValidator,
                activityReporter: ActivityReporterProtocol,
                recover2faWebService: Recover2FAWebService,
                completion: @escaping (DeviceToDeviceOTPLoginViewModel.CompletionType) -> Void) {
        self.validator = validator
        self.activityReporter = activityReporter
        self.recover2faWebService = recover2faWebService
        self.pushType = validator.option.pushType
        self.lostOTPSheetViewModel = LostOTPSheetViewModel(recover2faService: recover2faWebService)
        self.completion = completion
        if pushType != nil {
            showPushView = true
        }
    }

    public func sendPush() async {
        do {
            if pushType == .duo {
                try await validator.validateUsingDUOPush()
            } else {
                try await validator.validateUsingAuthenticatorPush()
            }
            state = .completed(L10n.Core.authenticatorPushViewAccepted, {
                self.inProgress = true
                self.completion(.success(isBackupCode: false))
            })
        } catch {
            self.logError()
            state = .failed(L10n.Core.authenticatorPushViewDeniedError, {

            })
            self.completion(.error(error))
        }
    }

    public func useBackupCode(_ code: String) {
        Task {
            await validate(code: code, isBackupCode: true)
        }
    }

    private func validate(code: String, isBackupCode: Bool = false) async {
        do {
            try await validator.validateOTP(code)
            inProgress = true
            self.completion(.success(isBackupCode: isBackupCode))
        } catch {
            self.logError(isBackupCode: isBackupCode)
            isTokenError = true
        }
    }

    func logError(isBackupCode: Bool = false) {
        activityReporter.report(UserEvent.Login(isBackupCode: isBackupCode,
                                                mode: .masterPassword,
                                                status: .errorWrongOtp,
                                                verificationMode: .otp1))
    }

    public func validate() {
        Task {
            await self.validate(code: otpValue)
        }
    }
}

extension ThirdPartyOTPOption {
    var pushType: PushType? {
        switch self {
        case .totp:
            return nil
        case .duoPush:
            return .duo
        case .authenticatorPush:
            return .authenticator
        }
    }
}
