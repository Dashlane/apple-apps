import CorePersonalData
import CorePremium
import CoreSettings
import CoreSharing
import CoreUserTracking
import DashlaneReportKit
import Foundation
import VaultKit

class VaultItemRowModel: SessionServicesInjecting, MockVaultConnectedInjecting {

    struct Configuration {
        let item: VaultItem
        let isSuggested: Bool
    }

    struct AdditionalConfiguration {
        let origin: Origin?
        let highlightedString: String?
        let quickActionsEnabled: Bool
        let shouldShowSharingStatus: Bool
        let shouldShowSpace: Bool

        init(
            origin: Origin? = nil,
            highlightedString: String? = nil,
            quickActionsEnabled: Bool = true,
            shouldShowSharingStatus: Bool = true,
            shouldShowSpace: Bool = true
        ) {
            self.origin = origin
            self.highlightedString = highlightedString
            self.quickActionsEnabled = quickActionsEnabled
            self.shouldShowSharingStatus = shouldShowSharingStatus
            self.shouldShowSpace = shouldShowSpace
        }
    }

    enum Origin {
        case vault
        case home
        case search
    }

    enum CopyResult {
        case success(fieldType: Definition.Field)
                case limitedRights
                case authenticationDenied
    }

    let item: VaultItem
    let origin: Origin?

    let highlightedString: String?

    let isSuggested: Bool
    let quickActionsEnabled: Bool
    let shouldShowSharingStatus: Bool
    let shouldShowSpace: Bool

    var space: UserSpace? {
        teamSpacesService.displayedUserSpace(for: item)
    }

    private let vaultIconViewModelFactory: VaultItemIconViewModel.Factory
    private let quickActionsMenuViewModelFactory: QuickActionsMenuViewModel.Factory

    private let userSettings: UserSettings
    private let itemPasteboard: ItemPasteboardProtocol
    private let usageLogService: UsageLogServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let activityReporter: ActivityReporterProtocol
    private let vaultItemsService: VaultItemsServiceProtocol
    private let sharingPermissionProvider: SharedVaultHandling

    init(
        configuration: VaultItemRowModel.Configuration,
        additionalConfiguration: VaultItemRowModel.AdditionalConfiguration? = nil,
        vaultIconViewModelFactory: VaultItemIconViewModel.Factory,
        quickActionsMenuViewModelFactory: QuickActionsMenuViewModel.Factory,
        userSettings: UserSettings,
        accessControl: AccessControlProtocol,
        usageLogService: UsageLogServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        teamSpacesService: TeamSpacesService,
        vaultItemsService: VaultItemsServiceProtocol,
        sharingPermissionProvider: SharedVaultHandling
    ) {
        self.item = configuration.item
        self.origin = additionalConfiguration?.origin
        self.isSuggested = configuration.isSuggested

        self.highlightedString = additionalConfiguration?.highlightedString
        self.quickActionsEnabled = additionalConfiguration?.quickActionsEnabled ?? true
        self.shouldShowSharingStatus = additionalConfiguration?.shouldShowSharingStatus ?? true
        self.shouldShowSpace = additionalConfiguration?.shouldShowSpace ?? true

        self.vaultIconViewModelFactory = vaultIconViewModelFactory
        self.quickActionsMenuViewModelFactory = quickActionsMenuViewModelFactory

        self.userSettings = userSettings
        self.itemPasteboard = ItemPasteboard(accessControl: accessControl, userSettings: userSettings)
        self.usageLogService = usageLogService
        self.activityReporter = activityReporter
        self.teamSpacesService = teamSpacesService
        self.vaultItemsService = vaultItemsService
        self.sharingPermissionProvider = sharingPermissionProvider
    }
}

extension VaultItemRowModel {
    func deleteBehaviour() async throws -> ItemDeleteBehaviour {
        try await sharingPermissionProvider.deleteBehaviour(for: item)
    }

    func delete() {
        vaultItemsService.delete(item)
    }
}

extension VaultItemRowModel {
    func copy(_ valueToCopy: String, fieldType: Definition.Field) async -> CopyResult? {
        guard let item = item as? CopiablePersonalData & VaultItem else {
            return nil
        }

        guard sharingPermissionProvider.canCopyProperties(in: item) else {
            return .limitedRights
        }

        var origin: Set<LastUseUpdateOrigin> = [.default]
        if highlightedString != nil {
            origin.insert(.search)
        }

        vaultItemsService.updateLastUseDate(of: [item], origin: origin)

        sendCopyUsageLog(fieldType: fieldType)
        let isSuccess = await itemPasteboard
            .copy(item, valueToCopy: valueToCopy).values.first { _ in true }

        return isSuccess == true ? .success(fieldType: fieldType) : .authenticationDenied
    }

    private func sendCopyUsageLog(fieldType: Definition.Field) {
        guard let origin else { return }

        var action  = "quickCopy"
        if let isUniversalClipboardEnabled: Bool = userSettings[.isUniversalClipboardEnabled],
           isUniversalClipboardEnabled {
            action += "Universal"
        }
        var website: String?
        if let item = item as? Credential {
            website = item.url?.domain?.name
        }
        usageLogService.post(
            UsageLogCode75GeneralActions(
                type: item.usageLogType75,
                subtype: fieldType.rawValue,
                action: action,
                subaction: origin.subAction,
                website: website,
                position: -1
            )
        )
        var isProtected = false
        if let secureItem = item as? SecureItem {
            isProtected = secureItem.secured
        }

        activityReporter.report(
            UserEvent.CopyVaultItemField(
                field: fieldType,
                highlight: origin.definitionHighlight(isSuggested),
                index: Double(-1),
                isProtected: isProtected,
                itemId: item.anonId,
                itemType: item.vaultItemType
            )
        )
        activityReporter.report(
            AnonymousEvent.CopyVaultItemField(
                domain: item.hashedDomainForLogs,
                field: fieldType,
                itemType: item.vaultItemType
            )
        )
    }
}

extension VaultItemRowModel.Origin {
    var subAction: String? {
        switch self {
        case .vault:
            return "itemsList"
        case .home:
            return "suggestedList"
        case .search:
            return "search"
        }
    }

    var highlight: Definition.Highlight {
        switch self {
        case .home:
            return .suggested
        case .search:
            return .searchResult
        default:
            return .none
        }
    }

    func definitionHighlight(_ isSuggested: Bool) -> Definition.Highlight {
        guard !isSuggested else {
            return .suggested
        }
        switch self {
        case .search:
            return .searchResult
        default:
            return .none
        }
    }
}

extension VaultItemRowModel {
    var vaultIconViewModel: VaultItemIconViewModel {
        vaultIconViewModelFactory.make(item: item)
    }

    var quickActionsMenuViewModel: QuickActionsMenuViewModel? {
        guard let origin else { return nil }
        return quickActionsMenuViewModelFactory.make(
            item: item,
            origin: origin,
            isSuggestedItem: isSuggested
        )
    }
}

extension VaultItemRowModel {

    static func mock(item: VaultItem) -> VaultItemRowModel {
        Self.mock(configuration: .init(item: item, isSuggested: false))
    }

    static func mock(
        configuration: Configuration,
        additionalConfiguration: AdditionalConfiguration? = nil
    ) -> VaultItemRowModel {
        MockVaultConnectedContainer().makeVaultItemRowModel(
            configuration: configuration,
            additionalConfiguration: additionalConfiguration
        )
    }
}
