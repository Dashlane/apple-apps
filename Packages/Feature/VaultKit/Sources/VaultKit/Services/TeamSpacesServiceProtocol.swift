import CorePersonalData
import CorePremium

public protocol TeamSpacesServiceProtocol: CorePremium.TeamSpacesServiceProtocol {
    var availableBusinessTeam: BusinessTeam? { get }

    func userSpace(for item: VaultItem) -> UserSpace?
    func userSpace(for collection: VaultCollection) -> UserSpace?
    func displayedUserSpace(for collection: VaultCollection) -> UserSpace?
    func displayedUserSpace(for item: VaultItem) -> UserSpace?
    func businessTeam(for item: VaultItem) -> BusinessTeam?
    func userSpace(withId teamId: String) -> UserSpace?
    func businessTeam(withId teamId: String) -> BusinessTeam?
}
