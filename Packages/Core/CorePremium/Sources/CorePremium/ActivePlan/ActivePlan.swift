public enum ActivePlan: Equatable {
    public enum PremiumType: Equatable {
        case freeForLife
                case freeOfCharge
        case standard
    }

            case legacy
        case free
        case essentials
        case advanced
        case trial
        case premium(PremiumType)
        case premiumPlus
        case premiumFamily(isAdmin: Bool)
        case premiumPlusFamily(isAdmin: Bool)
}
