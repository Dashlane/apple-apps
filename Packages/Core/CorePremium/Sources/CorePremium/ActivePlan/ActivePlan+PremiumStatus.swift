extension ActivePlan {
        public init(status: PremiumStatus) {
        switch status.statusCode {
        case .free:
            self = .free
        case .freeTrial:
            self = .trial
        case .legacy:
            self = .legacy
        case .premium, .grace, .premiumRenewalStopped:
            switch status.planFeature {
            case .sync where status.isPremiumFreeForLife():
                self = .premium(.freeForLife)
            case .sync where status.isPremiumFreeOfCharge:
                self = .premium(.freeOfCharge)
            case .sync:
                self = status.familyMembership?.isEmpty == false ? .premiumFamily(isAdmin: !status.isFamilyInvitee) : .premium(.standard)
            case .premiumPlus:
                self = status.familyMembership?.isEmpty == false ? .premiumPlusFamily(isAdmin: !status.isFamilyInvitee) : .premiumPlus
            case .essentials:
                self = .essentials
            case .advanced:
                self = .advanced
            case .none:
                self = .premium(.standard)
            }
        }
    }
}

extension PremiumStatus {
    public var humanReadableActivePlan: ActivePlan {
        .init(status: self)
    }
}
