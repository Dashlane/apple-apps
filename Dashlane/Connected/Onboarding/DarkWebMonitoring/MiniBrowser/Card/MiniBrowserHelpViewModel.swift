import Foundation

public class MiniBrowserHelpCardViewModel: ObservableObject {

    @Published
    var shouldShowDetailedInstructions = false

    let email: String
    let password: String
    let domain: String

    private let usageLogService: DWMLogService

    init(email: String, password: String, domain: String, usageLogService: DWMLogService) {
        self.email = email
        self.password = password
        self.domain = domain
        self.usageLogService = usageLogService
    }

    func showHideInstructions() {
        shouldShowDetailedInstructions.toggle()

        if shouldShowDetailedInstructions == true {
            usageLogService.log(.miniBrowserInstructionsDisplayed)
        }
    }
}
