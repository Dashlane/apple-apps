import SwiftUI

struct CredentialsListNoResultView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(asset: Asset.searchNoResult)
                .foregroundColor(Color(asset: Asset.selection))
            VStack(spacing: 16) {
                Text(L10n.Localizable.searchVaultNoResultFoundTitle)
                    .font(Typography.title)
                    .foregroundColor(Color(asset: Asset.primaryHighlight))
                Text(L10n.Localizable.searchVaultNoResultFoundDescription)
                    .font(Typography.body)
                    .foregroundColor(Color(asset: Asset.secondaryHighlight))
            }.multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .onAppear{
            guard NSWorkspace.shared.isVoiceOverEnabled else { return }
            NSAccessibility.post(
                element: NSApp.mainWindow as Any,
                notification: .announcementRequested,
                userInfo: [
                    .announcement: L10n.Localizable.searchVaultNoResultFoundTitle + " " + L10n.Localizable.searchVaultNoResultFoundDescription,
                    .priority: NSAccessibilityPriorityLevel.high.rawValue
                ]
            )
        }
    }
}

struct CredentialsListNoResultView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverPreviewScheme(size: .popoverContent) {
            CredentialsListNoResultView()
        }
    }
}
