import SwiftUI

struct PasswordGeneratorSaveDefaultView: View {

    let isDifferentFromDefaultConfiguration: Bool
    let savePreferences: () -> Void

    var body: some View {
        Button(title, action: savePreferences)
            .buttonStyle(DashlaneDefaultButtonStyle(backgroundColor: .clear,
                                                    borderColor: isDifferentFromDefaultConfiguration ? Color(asset: Asset.separation) : .clear,
                                                    foregroundColor: Color(asset: isDifferentFromDefaultConfiguration ? Asset.primaryHighlight : Asset.separation)))
            .frame(height: 32)
            .disabled(!isDifferentFromDefaultConfiguration)
    }
    
    private var title: String {
        if isDifferentFromDefaultConfiguration {
            return L10n.Localizable.passwordGeneratorSaveAsDefault
        } else {
            return L10n.Localizable.passwordGeneratorSavedAsDefault
        }
    }
}

struct PasswordGeneratorSaveDefaultView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverPreviewScheme {
            PasswordGeneratorSaveDefaultView(isDifferentFromDefaultConfiguration: false, savePreferences: {})
            PasswordGeneratorSaveDefaultView(isDifferentFromDefaultConfiguration: true, savePreferences: {})
        }
    }
}
