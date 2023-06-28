import Foundation

public class MiniBrowserHelpCardViewModel: ObservableObject {

    @Published
    var shouldShowDetailedInstructions = false

    let email: String
    let password: String
    let domain: String

    init(email: String, password: String, domain: String) {
        self.email = email
        self.password = password
        self.domain = domain
    }

    func showHideInstructions() {
        shouldShowDetailedInstructions.toggle()
    }
}
