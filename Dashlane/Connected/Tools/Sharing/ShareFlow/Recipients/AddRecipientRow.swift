import DesignSystem
import SwiftUI
import UIDelight

struct AddRecipientRow<Label: View>: View {
  let action: () -> Void

  @ViewBuilder
  let label: () -> Label

  var body: some View {
    HStack {
      label()
        .onTapWithFeedback(perform: action)
      Button(L10n.Localizable.kwAddButton, action: action)
        .controlSize(.mini)
        .style(mood: .neutral, intensity: .catchy)
        .fixedSize(horizontal: true, vertical: false)
    }
    .frame(maxWidth: .infinity, alignment: .leading)

  }
}

struct AddRecipientRow_Previews: PreviewProvider {
  static var previews: some View {
    AddRecipientRow {

    } label: {
      Text("Label")
    }
    .style(mood: .neutral, intensity: .catchy)

    AddRecipientRow {

    } label: {
      Text("Label")
    }
    .style(mood: .neutral, intensity: .quiet)
  }
}
