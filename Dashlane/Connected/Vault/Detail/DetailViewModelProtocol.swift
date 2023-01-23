import Combine
import CorePersonalData
import CorePremium
import CoreSharing
import DashlaneAppKit
import DashTypes
import Foundation
import VaultKit

protocol DetailViewModelProtocol: ObservableObject {
    associatedtype Item: VaultItem, Equatable

    var service: DetailService<Item> { get }
}

extension DetailViewModelProtocol {

    var item: Item {
        get {
            service.item
        }
        set {
            service.item = newValue
        }
    }

    var originalItem: Item {
        service.originalItem
    }

    var allCollections: [VaultCollection] {
        get {
            service.allCollections
        }
        set {
            service.allCollections = newValue
        }
    }

    var originalAllCollections: [VaultCollection] {
        service.originalAllCollections
    }

    var collections: [VaultCollection] {
        get {
            service.collections
        }
        set {
            service.collections = newValue
        }
    }

    var mode: DetailMode {
        get {
            service.mode
        }
        set {
            service.mode = newValue
        }
    }

        var copySuccessPublisher: PassthroughSubject<Bool, Never> {
        service.copySuccessPublisher
    }

    var toastPublisher: PassthroughSubject<String, Never> {
        service.toastPublisher
    }

        var sharingPermission: SharingPermission? {
        service.sharingPermission()
    }

    var hasLimitedRights: Bool {
        service.hasLimitedRights()
    }

        var isUserSpaceForced: Bool {
        service.isUserSpaceForced
    }

    var selectedUserSpace: UserSpace {
        get {
            service.selectedUserSpace
        }
        set {
            service.selectedUserSpace = newValue
        }
    }

    var availableUserSpaces: [UserSpace] {
        service.availableUserSpaces
    }

    var advertiseUserActivity: Bool {
        service.advertiseUserActivity
    }

        var alert: DetailViewAlert? {
        get {
            service.alert
        }
        set {
            service.alert = newValue
        }
    }

    var isLoading: Bool {
        service.isLoading
    }

    var shouldReveal: Bool {
        get {
            service.shouldReveal
        }
        set {
            service.shouldReveal = newValue
        }
    }

    func display(message: String) {
        service.display(message: message)
    }

    func reveal(fieldType: DetailFieldType) {
        service.reveal(fieldType: fieldType)
    }

    func copy(_ value: String, fieldType: DetailFieldType) {
        service.copy(value, fieldType: fieldType)
    }

    func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher {
        service.requestAccess(forReason: reason)
    }

    func requestAccess(_ completion: @escaping (Bool) -> Void) {
        service.requestAccess(completion)
    }

    func showInVault() {
        service.showInVault()
    }

    func addItemToCollection(named: String) {
        service.addItemToCollection(named: named)
    }

    func removeItem(from collection: VaultCollection) {
        service.removeItem(from: collection)
    }

        func cancel() {
        service.cancel()
    }

        func itemDeleteBehavior() async throws -> ItemDeleteBehaviour {
        try await service.itemDeleteBehavior()
    }

    func delete() async {
        await service.delete()
    }

        var canSave: Bool {
        service.canSave
    }

    func prepareForSaving() throws {
        try service.prepareForSaving()
    }

    func save() {
        service.save()
    }

    func saveIfViewing() {
        service.saveIfViewing()
    }

        func reportDetailViewAppearance() {
        service.reportDetailViewAppearance()
    }

        var iconViewModel: VaultItemIconViewModel {
        service.iconViewModel
    }

    func makeAttachmentsListViewModel() -> AttachmentsListViewModel? {
        service.makeAttachmentsListViewModel()
    }

    func makeAttachmentsSectionViewModel() -> AttachmentsSectionViewModel {
        service.makeAttachmentsSectionViewModel()
    }
}
