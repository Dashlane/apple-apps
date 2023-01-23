import Foundation
import SwiftTreats
import CoreSession

public class SelfHostedSSOViewModel {
    
    let login: String
    let authorisationURL: URL
    let completion: Completion<SSOCallbackInfos>
    
    public init(login: String,
         authorisationURL: URL,
         completion: @escaping Completion<SSOCallbackInfos>) {
        self.login = login
        self.authorisationURL = authorisationURL
        self.completion = completion
    }
    
    func didReceiveCallback(_ result: Result<URL, Error>) {
        guard let callbackURL = try? result.get() else {
                        self.completion(.failure(SSOAccountError.failedLoginOnSSOPage))
            return
        }

        guard let callbackInfos = SSOCallbackInfos(url: callbackURL) else {
            self.completion(.failure(AccountError.unknown))
            return
        }
        self.completion(.success(callbackInfos))
    }
}
