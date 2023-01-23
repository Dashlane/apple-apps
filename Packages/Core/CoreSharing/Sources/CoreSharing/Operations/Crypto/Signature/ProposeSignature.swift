import Foundation
import CyrilKit

struct ProposeSignature {
    let signatureId: String
    let producer: AuthenticationCodeProducer
    
        func base64EncodedString() throws -> String {
        guard let data = signatureId.data(using: .utf8) else {
            throw SignatureError(kind: .propose, reason: .unknown)
        }
        
        let code = producer.authenticationCode(for: data)
        return code.base64EncodedString()
    }
}

extension ProposeSignatureProducer {
    func create(forId id: String) throws -> String {
        try ProposeSignature(signatureId: id, producer: self)
            .base64EncodedString()
    }
}

extension SharingGroupMember {
    func createProposeSignature(using producer: AuthenticationCodeProducer) throws -> String {
        return try producer.create(forId: signatureId)
    }
    
                func verifyProposeSignature(using producer: AuthenticationCodeProducer) throws {
        guard status.isAcceptedOrPending else {
            return
        }
        
        guard let signature = proposeSignature else {
            throw SignatureError(kind: .propose, reason: .emptyOrInvalidBase64)
        }
        
        let expected = try ProposeSignature(signatureId: signatureId, producer: producer).base64EncodedString()
        guard expected == signature else {
            throw SignatureError(kind: .propose, reason: .notValid)
        }
    }
}

extension Collection where Element: SharingGroupMember {
                func verifyProposeSignatures(using producer: AuthenticationCodeProducer) throws {
        for item in self {
            try item.verifyProposeSignature(using: producer)
        }
    }
}

