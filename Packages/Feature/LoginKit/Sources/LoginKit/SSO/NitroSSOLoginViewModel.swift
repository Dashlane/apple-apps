import Foundation
import SwiftTreats
import CoreSession
import CoreCrypto
import CoreNetworking

@MainActor
public class NitroSSOLoginViewModel: ObservableObject {
    
    @Published
    var loginService: NitroSSOLoginHandler?
    let login: String
    let webservice: NitroAPIClient
    let completion: Completion<SSOCallbackInfos>
    
    public init(login: String,
                nitroWebService: NitroAPIClient,
                completion: @escaping Completion<SSOCallbackInfos>) {
        self.login = login
        self.webservice = nitroWebService
        self.completion = completion
        Task {
            do {
                loginService = try await NitroSSOLoginHandler(login: login, webservice: webservice)
            } catch {
                self.completion(.failure(error))
            }
        }
    }
   
    func didReceiveSAML(_ result: Result<String, Error>) {
        switch result {
        case let .success(saml):
            Task { @MainActor in
                await self.completeLogin(withSAML: saml)
            }
        case let .failure(error):
            self.completion(.failure(error))
        }
    }
    
    func completeLogin(withSAML saml: String) async {
        do {
            guard let loginService = loginService else {
                assertionFailure()
                return
            }
            let callbackInfos = try await loginService.callbackInfo(withSAML: saml)
            await MainActor.run {
                completion(.success(callbackInfos))
            }
        } catch {
            await MainActor.run {
                completion(.failure(error))
            }
        }
    }
}
