import Foundation
import CorePersonalData
import Combine
import CoreUserTracking
import DashlaneReportKit
import DashlaneAppKit
import CoreSettings
import VaultKit
import DashTypes
import CoreSharing

class QuickActionsMenuViewModel: SessionServicesInjecting, MockVaultConnectedInjecting {
    let item: VaultItem
    let copyResultPublisher = PassthroughSubject<VaultItemRowModel.CopyResult, Never>()
    let sharingService: SharedVaultHandling
    let vaultItemsService: VaultItemsServiceProtocol
    let usageLogService: UsageLogServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let userSettings: UserSettings
    let itemPasteboard: ItemPasteboardProtocol
    let origin: VaultItemRowModel.Origin
    let isSuggestedItem: Bool
    let shareFlowViewModelFactory: ShareFlowViewModel.Factory
    let sharingDeactivationReason: SharingDeactivationReason?
    private var subscriptions  = Set<AnyCancellable>()

    init(item: VaultItem,
         sharingService: SharedVaultHandling,
         accessControl: AccessControlProtocol,
         usageLogService: UsageLogServiceProtocol,
         vaultItemsService: VaultItemsServiceProtocol,
         teamSpacesService: TeamSpacesService,
         activityReporter: ActivityReporterProtocol,
         userSettings: UserSettings,
         shareFlowViewModelFactory: ShareFlowViewModel.Factory,
         origin: VaultItemRowModel.Origin,
         isSuggestedItem: Bool) {
        self.vaultItemsService = vaultItemsService
        self.sharingService = sharingService
        self.usageLogService = usageLogService
        self.item = item
        self.shareFlowViewModelFactory = shareFlowViewModelFactory
        self.sharingDeactivationReason = teamSpacesService.businessTeamsInfo.isSharingDisabled() ? .b2bSharingDisabled : nil
        self.userSettings = userSettings
        self.activityReporter = activityReporter
        self.origin = origin
        self.isSuggestedItem = isSuggestedItem
        self.itemPasteboard = ItemPasteboard(accessControl: accessControl, userSettings: userSettings)
    }
}

extension QuickActionsMenuViewModel {
        func deleteBehaviour() async throws -> ItemDeleteBehaviour {
        try await sharingService.deleteBehaviour(for: item)
    }

    func delete() {
        vaultItemsService.delete(item)
        activityReporter.reportPageShown(.confirmItemDeletion)
    }

        func copy(fieldType: Definition.Field, valueToCopy: String) {
        guard sharingService.canCopyProperties(in: item) else {
            copyResultPublisher.send(.limitedRights)
            return
        }

        var lastUpdateOrigin: Set<LastUseUpdateOrigin> = [.default]
        if origin == .search {
            lastUpdateOrigin.insert(.search)
        }

        vaultItemsService.updateLastUseDate(of: [item], origin: lastUpdateOrigin)

        sendCopyUsageLog(fieldType: fieldType)

        itemPasteboard
            .copy(item, valueToCopy: valueToCopy)
            .map { $0 ? .success(fieldType: fieldType) : .authenticationDenied }
            .sink(receiveValue: copyResultPublisher.send)
            .store(in: &subscriptions)
    }

}

extension QuickActionsMenuViewModel {
    func sendCopyUsageLog(fieldType: Definition.Field) {
        var action  = "quickCopy"
        if let isUniversalClipboardEnabled: Bool = userSettings[.isUniversalClipboardEnabled],
            isUniversalClipboardEnabled {
            action += "Universal"
        }
        var website: String?
        if let item = item as? Credential {
            website = item.url?.domain?.name
        }
        usageLogService.post(UsageLogCode75GeneralActions(type: item.usageLogType75,
                                                          subtype: fieldType.rawValue,
                                                          action: action,
                                                          subaction: origin.subAction,
                                                          website: website))

        activityReporter.reportPageShown(.homeQuickActionsDropdown)
        var isProtected = false
        if let secureItem = item as? SecureItem {
            isProtected = secureItem.secured
        }
        activityReporter.report(UserEvent.CopyVaultItemField(field: fieldType,
                                                             highlight: origin.definitionHighlight(isSuggestedItem),
                                                             isProtected: isProtected,
                                                             itemId: item.userTrackingLogID,
                                                             itemType: item.vaultItemType))
        activityReporter.report(AnonymousEvent.CopyVaultItemField(domain: item.hashedDomainForLogs,
                                                                  field: fieldType,
                                                                  itemType: item.vaultItemType))
    }

    func reportAppearance() {
        activityReporter.report(UserEvent.OpenVaultItemDropdown(dropdownType: .quickActions, itemType: item.vaultItemType))
    }
}

extension QuickActionsMenuViewModel {
    static func mock(item: VaultItem) -> QuickActionsMenuViewModel {
        QuickActionsMenuViewModel(
            item: item,
            sharingService: SharedVaultHandlerMock(),
            accessControl: FakeAccessControl(accept: true),
            usageLogService: UsageLogService.fakeService,
            vaultItemsService: MockServicesContainer().vaultItemsService,
            teamSpacesService: .mock(),
            activityReporter: .fake,
            userSettings: .mock,
            shareFlowViewModelFactory: .init { _, _, _ in .mock() },
            origin: .home,
            isSuggestedItem: true
        )
    }
}
