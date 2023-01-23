import SwiftUI
import CorePersonalData
import DashTypes
import CoreLocalization

extension View {
    @ViewBuilder
    func limitedRights(allowViewing: Bool = true,
                       hasInfoButton: Bool = true,
                       item: PersonalDataCodable) -> some View {
        if item.isShared && item.metadata.sharingPermission == .limited, let sharingType = item.metadata.contentType.sharingType {
            self.modifier(SharingAlertFieldModifier(sharingType: sharingType,
                                                    allowViewing: allowViewing,
                                                    hasInfoButton: hasInfoButton))
        } else {
            self
        }
    }
}

struct SharingAlertFieldModifier: ViewModifier {

    @State
    var showAlert: Bool = false

    @Environment(\.detailMode)
    var detailMode

    let sharingType: SharingType
    let allowViewing: Bool
    let hasInfoButton: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        ZStack {
            if detailMode.isEditing || !allowViewing {
                HStack {
                    content
                        .environment(\.detailMode, .limitedViewing)
                    if hasInfoButton {
                        Image(asset: FiberAsset.passwordMissingImage)
                            .foregroundColor(Color(asset: FiberAsset.accentColor))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            self.showAlert = true
                        }
                )
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(""), message: Text(sharingType.limitedRightsAlertTitle))
                }
            } else {
                content
            }
        }
    }
}

extension SharingType {
    public var limitedRightsAlertTitle: String {
        switch self {
        case .password:
            return CoreLocalization.L10n.Core.kwLimitedRightMessage
        case .note:
            return CoreLocalization.L10n.Core.kwSecureNoteLimitedRightMessage
        }
    }
}
