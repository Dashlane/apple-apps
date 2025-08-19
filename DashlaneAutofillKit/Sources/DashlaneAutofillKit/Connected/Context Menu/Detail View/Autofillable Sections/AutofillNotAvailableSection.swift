import CoreLocalization
import DesignSystem
import SwiftUI

struct AutofillNotAvailableSection<Content: View>: View {
  let content: Content
  var shouldBeDisplayed: Bool

  init(@ViewBuilder content: () -> Content, shouldBeDisplayed: () -> Bool) {
    self.content = content()
    self.shouldBeDisplayed = shouldBeDisplayed()
  }

  var body: some View {
    if shouldBeDisplayed {
      Section {
        DS.Infobox(CoreL10n.contextMenuAutofillYouCanStillCopyAndPaste)
          .style(mood: .neutral)
          .listRowSeparator(.hidden)

        content
      } header: {
        Text(CoreL10n.contextMenuAutofillAutofillUnavailable)
          .foregroundStyle(Color.ds.text.neutral.quiet)
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
  }

}

#Preview("No content") {
  List {
    AutofillNotAvailableSection {
      EmptyView()
    } shouldBeDisplayed: {
      false
    }
  }
  .listStyle(.ds.insetGrouped)
}

#Preview("Content") {
  List {
    AutofillNotAvailableSection {
      Text("Not autofillable text")
    } shouldBeDisplayed: {
      true
    }
  }
  .listStyle(.ds.insetGrouped)
}
