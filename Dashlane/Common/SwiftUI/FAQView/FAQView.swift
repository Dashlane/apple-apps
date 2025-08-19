import SwiftUI
import UIDelight

struct FAQView: View {
  enum Completion {
    case faqSectionShown
    case itemOpened(item: FAQItem)
  }

  var items: [FAQItem]
  let completion: ((Completion) -> Void)?

  @State
  private var selectedItem: FAQItem?

  var body: some View {
    VStack {
      ForEach(items, id: \.self) { item in
        FAQItemView(item: item, selectedItem: $selectedItem)
      }
    }
    .edgesIgnoringSafeArea(.bottom)
    .onAppear {
      self.completion?(.faqSectionShown)
    }
    .onChange(of: selectedItem) { _, newValue in
      guard let newValue else { return }
      completion?(.itemOpened(item: newValue))
    }
  }
}

struct FAQView_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      FAQView(items: [
        FAQItem(title: "Title 1", description: "This is a description for the first FAQ item.")
      ]) { _ in }
    }
    .previewLayout(.sizeThatFits)
  }
}
