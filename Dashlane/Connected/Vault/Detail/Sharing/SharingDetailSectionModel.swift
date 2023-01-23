import Foundation
import VaultKit
import DashlaneReportKit
import Combine

@MainActor
struct SharingDetailSectionModel: SessionServicesInjecting, MockVaultConnectedInjecting {
    let item: VaultItem
    let usageLogService: UsageLogServiceProtocol
    private let sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory
    private let shareButtonModelFactory: ShareButtonViewModel.Factory

    public init(item: VaultItem,
                usageLogService: UsageLogServiceProtocol,
                sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
                shareButtonModelFactory: ShareButtonViewModel.Factory) {
        self.item = item
        self.usageLogService = usageLogService
        self.sharingMembersDetailLinkModelFactory = sharingMembersDetailLinkModelFactory
        self.shareButtonModelFactory = shareButtonModelFactory
    }

    func shareUsageLog() {
        let fromType: UsageLogCode80SharingUX.FromType

        switch self.item.metadata.contentType.sharingType {
        case .note:
            fromType = .secureNotes
        case .password:
            fromType = .credentials
        case .none:
            return
        }

        let log = UsageLogCode80SharingUX(type: .newShare1,
                                          action: .open,
                                          from: fromType)
        usageLogService.post(log)
    }

    func makeShareButtonViewModel() -> ShareButtonViewModel {
       return shareButtonModelFactory.make(items: [item])
    }

    func makeSharingMembersDetailLinkModel() -> SharingMembersDetailLinkModel {
       return sharingMembersDetailLinkModelFactory.make(item: item)
    }
}

extension SharingDetailSectionModel {
    static func mock(item: VaultItem) -> SharingDetailSectionModel {
        SharingDetailSectionModel(item: item,
                                  usageLogService: UsageLogService.fakeService,
                                  sharingMembersDetailLinkModelFactory: .init { .mock(item: $0) },
                                  shareButtonModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) }) 
    }
}
