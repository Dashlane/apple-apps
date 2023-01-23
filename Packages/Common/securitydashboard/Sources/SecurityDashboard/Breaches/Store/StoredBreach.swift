import Foundation

public protocol StoreIdentifier { }

public struct StoredBreach {

        public enum Status: Int {
        case pending, acknowledged, viewed, solved, unknown
    }

                public let objectID: StoreIdentifier?

        public var breachID: BreachesService.Identifier {
        return breach.id
    }

        public let breach: Breach

        public let leakedPasswords: Set<BreachesService.Password>

        public let status: Status

        internal private(set) var information = [DataLeakInfo]()

        public init(objectID: StoreIdentifier,
                breach: Breach,
                leakedPasswords: Set<BreachesService.Password>,
                status: Status) {
        self.objectID = objectID
        self.breach = breach
        self.leakedPasswords = leakedPasswords
        self.status = status
    }

            public init(breach: Breach) {
        self.objectID = nil
        self.breach = breach
        self.leakedPasswords = []
        self.status = .pending
    }

    public init(_ storedBreach: StoredBreach, objectID: StoreIdentifier) {
        self = StoredBreach(storedBreach: storedBreach, objectID: objectID)
    }

    init(storedBreach: StoredBreach,
         objectID: StoreIdentifier? = nil,
         leakedPasswords: Set<BreachesService.Password>? = nil,
         status: Status? = nil,
         information: [DataLeakInfo]? = nil) {
        self.objectID = objectID ?? storedBreach.objectID
        self.breach = storedBreach.breach
        self.leakedPasswords = leakedPasswords ?? storedBreach.leakedPasswords
        self.status = status ?? storedBreach.status
        self.information = information ?? storedBreach.information
    }

        func mutated(with objectID: StoreIdentifier? = nil, status: Status? = nil) -> StoredBreach {
        return StoredBreach(storedBreach: self, objectID: objectID, status: status)
    }

        func updated(with leakedPasswords: Set<BreachesService.Password>) -> StoredBreach {
        return StoredBreach(storedBreach: self, leakedPasswords: self.leakedPasswords.union(leakedPasswords))
    }

    func leakedPasswords(for authentifiants: [SecurityDashboardCredential]) -> Set<BreachesService.Password> {

                guard (self.breach.leakedData ?? []).contains(.password) else { return self.leakedPasswords }

                guard !self.information.leaked(.password) else { return self.leakedPasswords }

        let breachedPasswords = Set(authentifiants
            .filter {
                guard let domain = $0.domain else { return false }
                                guard breach.domains?.contains(domain) ?? false else { return false }
                guard let breachEventDate = breach.eventDate else { return false }
                                return breachEventDate.posterior(to: $0.lastModificationDate)

            }
            .compactMap { $0.password })

        return breachedPasswords.union(self.leakedPasswords)
    }
}

extension StoredBreach: Equatable, Hashable {

    public static func == (lhs: StoredBreach, rhs: StoredBreach) -> Bool {
        return lhs.breachID == rhs.breachID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(breachID)
    }
}

extension StoredBreach {
    func updated(with info: DataLeakInfo) -> StoredBreach {
                        let newBreach = info.data.reduce(into: StoredBreach(storedBreach: self, information: [info])) { (result, info) in
            switch info.type {
            case .password:
                                result = result.updated(with: Set<BreachesService.Password>([info.value]))
            default:
                                break
            }
        }
        return newBreach
    }
}
