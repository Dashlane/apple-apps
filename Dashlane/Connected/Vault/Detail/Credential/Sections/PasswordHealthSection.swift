import CorePersonalData
import SwiftUI
import UIDelight

struct PasswordHealthSection: View {

    @ObservedObject
    var model: PasswordHealthSectionModel

    var body: some View {
        Section(header: Text(L10n.Localizable.authentifiantDetailSafetyTitle.uppercased())) {
            complexityRow

            model.reusedCount.map { reusedCount in
                PartlyModifiedText(text: L10n.Localizable.authentifiantDetailSafetyPasswordReused(reusedCount),
                                   toBeModified: String(reusedCount),
                                   toBeModifiedModifier: { $0.foregroundColor(.red) })
            }

            if model.isCompromised {
                Text(L10n.Localizable.authentifiantDetailSafetyPasswordBreached)
                    .foregroundColor(.red)
            }
        }
    }

    private var complexityRow: some View {
        let complexityText = L10n.Localizable.passwordDetailText(for: model.passwordStrength)
        return PartlyModifiedText(text: L10n.Localizable.authentifiantDetailSafetyPasswordComplexity(complexityText),
                                  toBeModified: complexityText,
                                  toBeModifiedModifier: {
            $0.foregroundColor(Color(passwordStrength: model.passwordStrength))
        })
    }
}

struct PasswordHealthSection_Previews: PreviewProvider {

    private static let weakCredential: Credential = {
        var credential = PersonalDataMock.Credentials.amazon
        credential.password = "password"
        return credential
    }()

    private static let notSoStrongCredential: Credential = {
        var credential = PersonalDataMock.Credentials.amazon
        credential.password = "ImANotTooBad0"
        credential.numberOfUse = 42
        return credential
    }()

    private static let superStrongButCompromisedCredential: Credential = {
        var credential = PersonalDataMock.Credentials.amazon
        credential.password = "1AmV3rYSr°ng"
        credential.note = "compromised"
        return credential
    }()

    static var previews: some View {
        MultiContextPreview {
            List {
                PasswordHealthSection(model: .mock(service: .mock(item: weakCredential, mode: .viewing)))
                PasswordHealthSection(model: .mock(service: .mock(item: notSoStrongCredential, mode: .viewing)))
                PasswordHealthSection(model: .mock(service: .mock(item: superStrongButCompromisedCredential, mode: .viewing)))
            }
        }
    }
}
