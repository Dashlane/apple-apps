import Foundation
import CyrilKit
import DashTypes

extension SharingUpdater {
        @discardableResult
                func verifyAndSave(_ groups: [UserGroup]) throws -> [UserGroup] {
        logger.debug("Verify User Groups")
        let groups = groups.filter { group in
            do {
                try verify(group)
                return true
            } catch {
                logger.fatal("UserGroup \(group.id) is not valid: \(error)")
                return false
            }
        }
        
        guard !groups.isEmpty else {
            logger.debug("No UserGroup inserted or updated")
            return []
        }
        
        try database.save(groups)
       
        logger.debug("\(groups.count) UserGroup(s) inserted or updated")

        return groups
    }
    
    private func verify(_ group: UserGroup) throws {
        guard let groupKey = try groupKeyProvider.groupKey(for: group) else {
                                                return
        }
        
        if let user = group.user(with: userId) {
            try verifyAcceptSignature(of: user, groupKey: groupKey)
        }
  
        let proposeSignatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)
        try group.users.filter { $0.rsaStatus == .sharingKeys }.verifyProposeSignatures(using: proposeSignatureProducer)
        let _ = try group.info.privateKey(using: cryptoProvider.cryptoEngine(using: groupKey))
    }

        @discardableResult
                func verifyAndSave(_ groups: [ItemGroup]) throws -> [ItemGroup] {
        logger.debug("Verify Item Groups")
        let groups = groups.filter { group in
            do {
                try verify(group)
                return true
            } catch {
                logger.fatal("ItemGroup \(group.id) is not valid: \(error)")
                return false
            }
        }
        
        guard !groups.isEmpty else {
            logger.debug("No ItemGroup inserted or updated")
            return []
        }
        
        try database.save(groups)
        logger.debug("\(groups.count) ItemGroup(s) inserted or updated")

        return groups
    }
    
    private func verify(_ group: ItemGroup) throws {
        guard let groupKey = try groupKeyProvider.groupKey(for: group) else {
                                                return
        }
        
                if let user = group.user(with: userId) {
            try verifyAcceptSignature(of: user, groupKey: groupKey)
        }
        
        for userGroupMember in group.userGroupMembers {
            try verifyAcceptSignature(of: userGroupMember, groupKey: groupKey)
        }
        
                let proposeSignatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)
        try group.users.filter { $0.rsaStatus == .sharingKeys }.verifyProposeSignatures(using: proposeSignatureProducer)
        try group.userGroupMembers.verifyProposeSignatures(using: proposeSignatureProducer)
        
                let cryptoEngine = cryptoProvider.cryptoEngine(using: groupKey)
        for item in group.itemKeyPairs {
            let _ = try item.key(using: cryptoEngine)
        }
    }
    
        private func verifyAcceptSignature(of user: User, groupKey: SymmetricKey) throws {
        guard user.status == .accepted else {
            return
        }
        let acceptSignatureVerifier = cryptoProvider.acceptSignatureVerifier(using: try userKeyProvider().publicKey)
        try user.verifyAcceptSignature(using: acceptSignatureVerifier, groupKey: groupKey)
    }
    
    private func verifyAcceptSignature(of userGroupMember: UserGroupMember, groupKey: SymmetricKey) throws {
        guard userGroupMember.status == .accepted,
                            let pair = try database.fetchUserGroupUserPair(withGroupId: userGroupMember.id, userId: userId) else {
            return
        }
        
        let publicKey = try cryptoProvider.publicKey(fromPemString: pair.group.publicKey)
        let acceptSignatureVerifier = cryptoProvider.acceptSignatureVerifier(using: publicKey)
        try userGroupMember.verifyAcceptSignature(using: acceptSignatureVerifier, groupKey: groupKey)
    }
}

