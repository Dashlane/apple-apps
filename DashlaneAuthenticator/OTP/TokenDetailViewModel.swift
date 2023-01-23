import Foundation
import AuthenticatorKit

class TokenDetailViewModel: ObservableObject {
    let token: OTPInfo
    
    @Published
    var title: String
    
    @Published
    var issuer: String
    
    @Published
    var email: String
    
    @Published
    var showAlert = false
    
    var canSave: Bool {
        !title.isEmpty &&
        !issuer.isEmpty &&
        !email.isEmpty &&
        hasChanges
    }
    
    var hasChanges: Bool {
        title != token.configuration.title ||
        issuer != token.configuration.issuer ||
        email != token.configuration.login
    }
    
    private let databaseService: AuthenticatorDatabaseServiceProtocol
    let tokenAction: (TokenRowAction) -> Void
    
    init(token: OTPInfo,
         databaseService: AuthenticatorDatabaseServiceProtocol,
         tokenAction: @escaping (TokenRowAction) -> Void) {
        self.token = token
        title = token.configuration.title
        issuer = token.configuration.issuer ?? ""
        email = token.configuration.login
        self.databaseService = databaseService
        self.tokenAction = tokenAction
    }
    
    func makeGeneratedOTPCodeRowViewModel() -> GeneratedOTPCodeRowViewModel {
        GeneratedOTPCodeRowViewModel(token: token, databaseService: databaseService)
    }
    
    func save() {
        var token = token
        token.configuration.title = title
        token.configuration.issuer = issuer
        token.configuration.login = email
        tokenAction(.update(token))
    }
    
    func delete() {
        try? databaseService.delete(token)
        tokenAction(.didDelete(token))
    }
}
