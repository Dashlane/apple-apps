import Foundation
import DashTypes
import CoreSession
import DashlaneAppKit
import CoreNetworking

@MainActor
class TwoFAPhoneNumberSetupViewModel: ObservableObject, SessionServicesInjecting {

    let option: TFAOption

    @Published
    var phoneNumber: String = "" {
        didSet {
            isPhoneNumberInvalid = false
        }
    }

    @Published
    var selectedCountry: Country = Country(code: System.country)

    @Published
    var inProgress = false

    @Published
    var isPhoneNumberInvalid = false

    @Published
    var showError = false

    var code: String {
        countryPhoneCode(for: selectedCountry.code)
    }

    let countryList: [Country] = {
        var codes = Locale.Region.isoRegions.compactMap { code in
            return Country(code: code.identifier)
        }
       return codes
            .sorted {
           $0.name < $1.name
       }
    }()

    let userAPIClient: UserDeviceAPIClient
    let regionInformationService: RegionInformationService
    let completion: (TOTPActivationResponse?) -> Void

    init(userAPIClient: UserDeviceAPIClient,
         option: TFAOption,
         regionInformationService: RegionInformationService,
         completion: @escaping (TOTPActivationResponse?) -> Void) {
        self.userAPIClient = userAPIClient
        self.option = option
        self.regionInformationService = regionInformationService
        self.completion = completion
    }

    func countryPhoneCode(for country: String) -> String {
        guard let code = self.regionInformationService.callingCodes.code(forCountry: country)?.dialingCode else {
            return ""
        }
        return String(code)
    }

    func complete() {
        inProgress = true
        Task {
            await requestTOTPActivation()
        }
    }

    func requestTOTPActivation() async {
        do {
            let result = try await self.userAPIClient.authentication.requestTOTPActivation(phoneNumber: code + phoneNumber, country: selectedCountry.code)
            inProgress = false
            self.completion(result)
        } catch let error as DashlaneAPI.APIError where error.hasAccountCode(APIErrorCodes.Account.phoneValidationFailed) {
            isPhoneNumberInvalid = true
            inProgress = false
        } catch {
            inProgress = false
            self.showError = true
        }
    }
}

extension TwoFAPhoneNumberSetupViewModel {
    static func mock(_ option: TFAOption) -> TwoFAPhoneNumberSetupViewModel {
                return try! .init(userAPIClient: .fake,
                          option: option,
                          regionInformationService: RegionInformationService(),
                          completion: { _ in })
    }
}
