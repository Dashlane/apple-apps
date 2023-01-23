import SwiftUI
import SwiftTreats
import UIComponents
import Combine
import VaultKit
import CoreUserTracking
import CorePremium

extension DetailContainerView {
    func onCopyAction(_ success: Bool) {
        guard success else {
            return
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        toast(L10n.Localizable.kwCopied, image: .ds.action.copy.outlined)
    }

    func showSpaceSelectorListView() {
                UIApplication.shared.endEditing()
        showSpaceSelector = true
    }

    func save() {
        if let specificSave {
            specificSave()
        } else {
            model.save()
        }

                if self.model.mode.isAdding && Device.isIpadOrMac {
            navigator()?.dismiss()
            model.showInVault()
        } else {
            self.model.mode = .viewing
        }
    }

    func delete() {
        Task {
            await self.model.delete()
            await MainActor.run { self.dismiss() }
        }
    }
}

extension DetailService: AccessControlProtocol {
    func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher {
        guard !hasSecureAccess else {
            return Just(true)
                .eraseToAnyPublisher()
        }

        return accessControl
            .requestAccess(forReason: reason)
            .handleEvents(receiveOutput: { success in
                self.hasSecureAccess = success
            }).eraseToAnyPublisher()
    }

        func reveal(fieldType: DetailFieldType) {
        guard shouldReveal == false,
              Item.requireSecureAccess else {
            toggleReveal(!shouldReveal)
            sendViewUsageLog(for: fieldType)
            return
        }

        if mode.isAdding {
            self.shouldReveal = true
        } else {
            self.requestAccess { [weak self] hasAccess in
                guard let self = self else {
                    return
                }
                self.toggleReveal(hasAccess)
                if hasAccess {
                    self.sendViewUsageLog(for: fieldType)
                }
            }
        }
    }

    private func toggleReveal(_ reveal: Bool) {
        self.shouldReveal = reveal
        updateLastLocalUseDate()
    }

    private func updateLastLocalUseDate() {
        if !self.mode.isEditing {
            vaultItemsService.updateLastUseDate(of: [item], origin: [.default])
        }
    }

    func copy(_ value: String, fieldType: DetailFieldType) {
        updateLastLocalUseDate()
        copyActionSubcription = itemPasteboard
            .copy(value, for: item, hasSecureAccess: hasSecureAccess)
            .sink { success in
                self.hasSecureAccess = success
                self.copySuccessPublisher.send(success)
                if success {
                    self.sendCopyUsageLog(fieldType: fieldType)
                }
        }
    }

    func display(message: String) {
        toastPublisher.send(message)
    }

    func showInVault() {
        deepLinkService.handleLink(.vault(.show(item, useEditMode: false, origin: .adding)))
    }

    func makeAttachmentsListViewModel() -> AttachmentsListViewModel? {
        let publisher = vaultItemsService
            .itemPublisher(for: item)
            .map { $0 as VaultItem }
            .eraseToAnyPublisher()
        return attachmentsListViewModelProvider(item, publisher)
    }

    func makeAttachmentsSectionViewModel() -> AttachmentsSectionViewModel {
        let publisher = vaultItemsService
            .itemPublisher(for: item)
            .map { $0 as VaultItem }
            .eraseToAnyPublisher()
        return attachmentSectionFactory.make(item: item, itemPublisher: publisher)
    }
}
