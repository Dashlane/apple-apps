import Foundation
import CoreSession
import DashTypes

struct SessionLoader {
    let shareableSession: ShareableUserSession
    let container: SessionsContainerProtocol
    
    enum LoaderError: Error {
        case cannotLoadAccount
    }
    
    func session() throws -> Session {
        if let masterPassword = shareableSession.masterPassword {
            return try fetchSession(fromMasterPassword: masterPassword, serverKey: shareableSession.serverKey)
        } else if let remoteKey = shareableSession.remoteKey {
            return try fetchSession(fromRemoteKey: remoteKey)
        } else {
            throw LoaderError.cannotLoadAccount
        }
    }
    
    private func createSession(forLogin login: String, with masterKey: CoreSession.MasterKey) throws -> Session {
        return try container.loadSession(for: LoadSessionInformation(login: Login(login), masterKey: masterKey))
    }
    
    private func fetchSession(fromMasterPassword masterPassword: String, serverKey: String?) throws -> Session {
        let masterKey = CoreSession.MasterKey.masterPassword(masterPassword,
                                                     serverKey: serverKey)
        let session = try self.createSession(forLogin: shareableSession.login, with: masterKey)
        return session
    }
    
    private func fetchSession(fromRemoteKey remoteKey: Data) throws -> Session {
        let masterKey = CoreSession.MasterKey.ssoKey(remoteKey)
        let session = try createSession(forLogin: shareableSession.login, with: masterKey)
        return session
    }
}
