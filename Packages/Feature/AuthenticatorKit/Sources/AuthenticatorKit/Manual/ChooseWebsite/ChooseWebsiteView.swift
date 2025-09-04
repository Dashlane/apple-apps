import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight

public struct ChooseWebsiteView: View {

  @StateObject
  var viewModel: ChooseWebsiteViewModel

  @State
  var isActive = false

  public init(viewModel: ChooseWebsiteViewModel) {
    self._viewModel = .init(wrappedValue: viewModel)
  }

  public var body: some View {
    ScrollView {
      if viewModel.searchCriteria.isEmpty {
        placeholderList
      } else {
        searchedWebsites
      }
    }
    .navigationBarTitleDisplayMode(.large)
    .navigationTitle(.init(CoreL10n.chooseServiceTitle))
    .frame(maxWidth: .infinity)
    .searchable(
      text: $viewModel.searchCriteria,
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: CoreL10n.chooseServiceSearchPlaceholder
    )
    .autocorrectionDisabled()
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  var placeholderList: some View {
    VStack(spacing: 8) {
      HStack {
        Text(CoreL10n.chooseServiceSuggestedSectionTitle.uppercased())
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .font(.footnote.weight(.medium))
        Spacer()
      }
      VStack(alignment: .leading, spacing: 0) {
        ForEach(viewModel.placeholderWebsites, id: \.self) { website in
          if website != viewModel.placeholderWebsites.first {
            Divider()
              .padding(.leading)
          }
          Button {
            self.viewModel.completion(website)
          } label: {
            HStack {

              PlaceholderWebsiteView(
                model: viewModel.placeholderViewModelFactory.make(website: website))
              Spacer()
            }.padding(.horizontal)
          }

          .foregroundStyle(Color.ds.text.neutral.standard)
        }
      }
      .frame(maxWidth: .infinity)
      .background(.ds.container.agnostic.neutral.supershy)
      .cornerRadius(8)
    }.padding([.horizontal, .bottom])
  }

  var searchedWebsites: some View {
    VStack {
      VStack(spacing: 0) {
        ForEach(viewModel.searchedWebsites, id: \.self) { website in
          if website != viewModel.searchedWebsites.first {
            Divider()
              .padding(.leading)
          }
          Button {
            self.viewModel.completion(website)
          } label: {
            HStack {
              Text(website)
              Spacer()
            }.padding(10)
          }
          .foregroundStyle(Color.ds.text.neutral.catchy)
        }
      }
      .frame(maxWidth: .infinity)
      .background(.ds.container.agnostic.neutral.supershy)
      .cornerRadius(8)
      .padding([.horizontal, .bottom])
      addAccountButton
        .font(.body.weight(.medium))
    }

  }

  var addAccountButton: some View {
    Button(CoreL10n.chooseServiceAddDetails) {
      self.viewModel.completion(self.viewModel.searchCriteria)
    }
    .foregroundStyle(Color.ds.text.brand.standard)
    .frame(maxWidth: .infinity)
  }
}

#Preview("Default") {
  NavigationView {
    ChooseWebsiteView(viewModel: .mock())
  }
}

#Preview("With Searched Websites") {
  NavigationView {
    ChooseWebsiteView(viewModel: .mock(includeSearchedWebsites: true))
  }
}
