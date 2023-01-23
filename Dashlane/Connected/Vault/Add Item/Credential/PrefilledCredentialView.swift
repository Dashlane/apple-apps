import SwiftUI
import CorePersonalData
import DashlaneAppKit
import VaultKit

struct PrefilledCredentialView: View {
    let title: String
    let credential: Credential
    let iconViewModel: VaultItemIconViewModel

    var body: some View {
        VStack(spacing: 10) {
            icon
                .fiberAccessibilityHidden(true)
            Text(title)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .allowsTightening(true)
                .minimumScaleFactor(0.7)
                .truncationMode(.tail)
        }
    }

    @ViewBuilder
    var icon: some View {
        DomainIconView(model: iconViewModel.makeDomainIconViewModel(credential: credential, size: .prefilledCredential),
                            placeholderTitle: credential.localizedTitle)
    }
}

struct PrefilledCredentialView_Previews: PreviewProvider {
    static let credential = Credential()
    static var previews: some View {
        Group {
            PrefilledCredentialView(title: "Facebook", credential: credential, iconViewModel: VaultItemIconViewModel.mock(item: credential))
            PrefilledCredentialView(title: "American Express", credential: credential, iconViewModel: VaultItemIconViewModel.mock(item: credential))

        }.frame(width: 60, height: 76, alignment: .top)
        .previewLayout(.sizeThatFits)
    }
}
