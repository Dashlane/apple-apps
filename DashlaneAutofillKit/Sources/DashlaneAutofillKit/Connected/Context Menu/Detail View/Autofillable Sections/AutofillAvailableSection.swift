import CoreLocalization
import DesignSystem
import SwiftUI

struct AutofillAvailableSection<Content: View>: View {
  let mood: Mood

  @ViewBuilder
  let content: () -> Content

  init(mood: Mood = .positive, @ViewBuilder content: @escaping () -> Content) {
    self.mood = mood
    self.content = content
  }

  var body: some View {
    Section {
      DS.Infobox(CoreL10n.contextMenuAutofillTapOnTheFieldYouWantToAutofill)
        .style(mood: mood)
        .listRowSeparator(.hidden)

      content()
    } header: {
      Text(CoreL10n.contextMenuAutofillAutofillAvailable)
        .foregroundStyle(Color.ds.text.neutral.quiet)
    }
    .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
  }
}

#Preview {
  List {
    AutofillAvailableSection {
      Text("Autofillable text")
    }
  }
  .listStyle(.ds.insetGrouped)
}
