import Foundation
import DashTypes
import CorePersonalData
import CoreSync
import CoreSharing

public protocol SharingSyncHandler {
    func sync(using sharingInfo: SharingSummaryInfo?) async throws
}


public protocol SharedVaultHandling: SharingSyncHandler {
    func permission(for item: PersonalDataCodable) -> SharingPermission?
    func deleteBehaviour(for item: PersonalDataCodable) async throws -> ItemDeleteBehaviour
    
    func refuseAndDelete(_ item: PersonalDataCodable) async throws
    
        func forceRevoke(_ credentials: [Credential]) async throws
}

public extension SharingPermission {
    var canCopy: Bool {
        return self != .limited
    }
    
    var canModify: Bool {
        return self != .limited
    }
}

public extension SharedVaultHandling {
    func canCopyProperties(in item: PersonalDataCodable) -> Bool {
        guard item.isShared, let permission = permission(for: item) else {
            return true
        }
        
        return permission.canCopy
    }
}

public struct SharedVaultHandlerMock: SharedVaultHandling {
    public let permission: SharingPermission
    public let deleteBehaviour: ItemDeleteBehaviour

    
    public init(permission: SharingPermission = .admin,
                deleteBehaviour: ItemDeleteBehaviour = .canDeleteByLeavingItemGroup) {
        self.permission = permission
        self.deleteBehaviour = deleteBehaviour
    }

    public func permission(for item: PersonalDataCodable) -> SharingPermission? {
        return permission
    }
    
    public func deleteBehaviour(for item: PersonalDataCodable) async -> ItemDeleteBehaviour {
        return deleteBehaviour
    }
    
    public func refuseAndDelete(_ item: PersonalDataCodable) async {
        
    }
    
    public func forceRevoke(_ credentials: [Credential]) async {
        
    }
    
    public func sync(using sharingInfo: SharingSummaryInfo?) async {
        
    }
}
