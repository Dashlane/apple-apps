import SwiftUI
import DashlaneAppKit
import CoreSettings

struct PasswordGeneratorSliderView: View {
    
    @Binding
    var preferences: PasswordGeneratorPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            lengthSectionHeader
            HStack {
                Text("4")
                SliderView(currentValue: $preferences.doubleLength, minValue: 4, maxValue: 40)
                    .accessibility(identifier: "Generator length")
                Text("40")
            }.foregroundColor(.secondary)
        }
    }
    
    var lengthSectionHeader: some View {
        Text(L10n.Localizable.kwPadExtensionGeneratorLength) + Text(" (\(preferences.length))")
    }
    
}

struct PasswordGeneratorSliderView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverPreviewScheme {
            PasswordGeneratorSliderView(preferences: Binding.constant(PasswordGeneratorPreferences()))
        }
    }
}
