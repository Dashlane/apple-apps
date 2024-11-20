import CoreLocalization
import SwiftUI

struct PasswordGeneratorSliderView: View {

  @ObservedObject
  var viewModel: PasswordGeneratorViewModel

  var body: some View {
    HStack {
      Text("4")
        .accessibilityHidden(true)
      Slider(value: $viewModel.preferences.doubleLength, in: 4...40, step: 1)
        .accessibility(identifier: "Generator length")
        .fiberAccessibilityLabel(Text(L10n.Core.kwPadExtensionGeneratorLengthAccessibility))
      Text("40")
        .accessibilityHidden(true)
    }.foregroundColor(.ds.text.neutral.standard)
  }
}

struct PasswordGeneratorSliderView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordGeneratorSliderView(viewModel: .mock)
  }
}
