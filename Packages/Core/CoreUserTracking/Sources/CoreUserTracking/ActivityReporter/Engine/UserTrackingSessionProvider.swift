import Foundation

struct UserTrackingSessionProvider {
    
    private static let fiveMinutes: TimeInterval = 5 * 60
    
    private var currentSession = Definition.Session()
    
    private var sessionExpirationDate = Date().addingTimeInterval(fiveMinutes)
    
    var isCurrentSessionValid: Bool {
        return Date() <= sessionExpirationDate
    }
    
    init() {}
    
        mutating func fetchSession() -> Definition.Session? {
        if isCurrentSessionValid {
            let session = currentSession
            currentSession.incrementingSequenceNumber()
            return session
        }
        return nil
    }
    
        mutating func refreshSession() {
        if !isCurrentSessionValid {
            currentSession = Definition.Session()
        }
        sessionExpirationDate = Date().addingTimeInterval(Self.fiveMinutes)
    }
}



private extension Definition.Session {
    
    init() {
        self.init(id: LowercasedUUID(), sequenceNumber: 1)
    }
    
    mutating func incrementingSequenceNumber() {
        self = Definition.Session(id: id, sequenceNumber: sequenceNumber + 1)
    }
}
