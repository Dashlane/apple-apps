#if os(iOS)
import Combine

extension DetailService: AccessControlProtocol {
    public func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher {
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
                self.eventPublisher.send(.copy(success))
                if success {
                    self.sendCopyUsageLog(fieldType: fieldType)
                }
            }
    }

    func showInVault() {
        deepLinkService.handle(.vault(.show(item, useEditMode: false, origin: .adding)))
    }
}
#endif
