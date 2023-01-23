import Foundation
import AuthenticationServices
import CorePersonalData


protocol CredentialProvider {


        func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier])
    
        func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity)

        func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity)
    
        func prepareInterfaceForExtensionConfiguration()
}


extension ASPasswordCredential {
    convenience init(credential: Credential) {
        self.init(user: credential.displayLogin, password: credential.password)
    }
}

extension ASExtensionError.Code {

    var nsError: NSError {
        return NSError(domain: ASExtensionErrorDomain, code: self.rawValue)
    }
}
