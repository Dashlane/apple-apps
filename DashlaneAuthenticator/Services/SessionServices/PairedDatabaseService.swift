import Foundation
import DashlaneAppKit
import CorePersonalData
import Combine
import TOTPGenerator
import UIKit
import DashTypes
import AuthenticatorKit
import VaultKit

class PairedDatabaseService: AuthenticatorDatabaseServiceProtocol, SessionCredentialsProvider {
   
    @Published
    public var codes: Set<OTPInfo> = []
    public var codesPublisher: AnyPublisher<Set<OTPInfo>, Never> { $codes.eraseToAnyPublisher() }
    
    @Published
    var isLoaded = false
    var isLoadedPublisher: AnyPublisher<Bool, Never> { $isLoaded.eraseToAnyPublisher() }
    
    @Published
    public var credentials: [Credential] = []
    public var credentialsPublisher: Published<[Credential]>.Publisher { $credentials }
    
    let login: String?
    let appDatabase: ApplicationDatabase
    private let databaseService: AuthenticatorDatabaseService
    
    private var cancellables = Set<AnyCancellable>()
    private let sharingService: SharedVaultHandling
    
    init(login: String,
         appDatabase: ApplicationDatabase,
         databaseService: AuthenticatorDatabaseService,
         sharingService: SharedVaultHandling) {
        self.login = login
        self.appDatabase = appDatabase
        self.databaseService = databaseService
        self.sharingService = sharingService
        load()
    }
    
    func credentialsWithFullRights() async -> [Credential] {
        return self.credentials.filter {
            $0.metadata.sharingPermission != .limited
        }
    }
    
    public func delete(_ item: OTPInfo) throws {
        if item.isDashlaneOTP {
            databaseService.delete(item)
        } else {
            guard var credential = try? appDatabase.fetch(with: item.id, type: Credential.self) else {
                assertionFailure("We should have a credential matching")
                return
            }
            credential.otpURL = nil
            try appDatabase.save(credential)
        }
    }
    
    public func add(_ items: [OTPInfo]) throws {
        
        let dashlaneCodes = items.filter {
            $0.isDashlaneOTP
        }
                
        let credentials: [Credential] = items.filter {
            !$0.isDashlaneOTP
        }
        .map(Credential.init)

        try databaseService.add(dashlaneCodes)
        try appDatabase.save(credentials)
    }
    
    public func update(_ item: OTPInfo) throws {
        
        guard !item.isDashlaneOTP else {
            try databaseService.update(item)
            return
        }
        guard var credentialHavingOTP = try? appDatabase.fetch(with: item.id, type: Credential.self) else {
            assertionFailure("We should find a credential with this ID \(item.id)")
            return
        }
        credentialHavingOTP.otpURL = item.configuration.otpURL
        credentialHavingOTP.isFavorite = item.isFavorite
        credentialHavingOTP.login = item.configuration.login
        credentialHavingOTP.title = item.configuration.title
        if let issuer = item.configuration.issuer {
            credentialHavingOTP.url = PersonalDataURL(rawValue: issuer)
        }
        try appDatabase.save(credentialHavingOTP)
    }
    
    public func link(_ otpInfo: OTPInfo, to credential: Credential) throws {
        
        var credential = credential
        credential.note = otpInfo.recoveryCodes.joined(separator: "\n")
        credential.otpURL = otpInfo.configuration.otpURL
        
        try appDatabase.save(credential)
    }
    
    func load() {
        databaseService.load()
        let credentials = appDatabase.itemsPublisher(for: Credential.self).shareReplayLatest()
        credentials.combineLatest(databaseService.codesPublisher)
            .map { credentials, dashlaneOTP -> (codes: Set<OTPInfo>, codesAndCredentials: [OTPInfo: Identifier]) in
                let credentialsAndOTPInfo: [OTPInfo: Identifier] = credentials.reduce(into: [OTPInfo: Identifier]()) { partialResult, credential in
                    guard let otpInfo = OTPInfo(credential: credential, supportDashlane2FA: true) else {
                        return
                    }
                    partialResult[otpInfo] = credential.id
                }
                let credentialsCodes = Array<OTPInfo>(credentialsAndOTPInfo.keys)
                let codes = Set(credentialsCodes + dashlaneOTP)
                return (codes, credentialsAndOTPInfo)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                self.codes = value.codes
                self.isLoaded = true
            }).store(in: &cancellables)
        credentials
            .map { Array($0) }
            .assign(to: &$credentials)
    }
    
    func copyDBToVault() {
        let codesToCopy: [Credential] = databaseService.codes.filter {
            !$0.isDashlaneOTP
        }.map(Credential.init)
        do {
            try appDatabase.save(codesToCopy)
            databaseService.codes.filter {
                !$0.isDashlaneOTP
            }.forEach(databaseService.delete)
        } catch {}
    }
}
