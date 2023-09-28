import SwiftUI
import DesignSystem
import CoreLocalization
import SwiftTreats

public struct BiometricQuickSetupView: View {
    let l10n = L10n.Core.PasswordlessAccountCreation.Biometry.self

    public enum CompletionResult {
        case useBiometry
        case skip
    }

    let biometry: Biometry
    let completion: (CompletionResult) -> Void

    public init(biometry: Biometry, completion: @escaping (CompletionResult) -> Void) {
        self.biometry = biometry
        self.completion = completion
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 58) {
                Image(biometry: biometry)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.ds.text.brand.standard)
                    .frame(width: 60)
                description
            }
            Spacer()
            actions
        }
        .padding(.top, 51)
        .padding(.bottom, 35)
        .padding(.horizontal, 24)
        .loginAppearance()
        .navigationTitle(l10n.navigationTitle)
    }
    var description: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(l10n.title(biometry.displayableName))
                .textStyle(.title.section.large)
            Text(l10n.message(biometry.displayableName))
                .textStyle(.body.standard.regular)
        }
    }

    var actions: some View {
        VStack(spacing: 8) {
            RoundedButton(l10n.useButton(biometry.displayableName)) {
                completion(.useBiometry)
            }
            .style(mood: .brand, intensity: .catchy)
            RoundedButton(l10n.skipButton) {
                completion(.skip)
            }
            .style(mood: .brand, intensity: .quiet)
        }
        .roundedButtonLayout(.fill)
    }
}

struct BiometricQuickSetupView_Previews: PreviewProvider {
    static var previews: some View {
        BiometricQuickSetupView(biometry: .faceId) { _ in

        }
    }
}

extension Image {
    init(biometry: Biometry) {
        switch biometry {
        case .touchId:
            self = .ds.fingerprint.outlined
        case .faceId:
            self = .ds.faceId.outlined
        }
    }
}
