#if canImport(UIKit)
  import SwiftUI
  import UIDelight
  import DesignSystem
  import CoreLocalization

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
      .navigationTitle(.init(L10n.Core.chooseServiceTitle))
      .navigationBarStyle(.brandedBarStyle)
      .frame(maxWidth: .infinity)
      .searchable(
        text: $viewModel.searchCriteria,
        placement: .navigationBarDrawer(displayMode: .always),
        prompt: L10n.Core.chooseServiceSearchPlaceholder
      )
      .autocorrectionDisabled()
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }

    var placeholderList: some View {
      VStack(spacing: 8) {
        HStack {
          Text(L10n.Core.chooseServiceSuggestedSectionTitle.uppercased())
            .foregroundColor(.ds.text.neutral.quiet)
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

            .foregroundColor(.ds.text.neutral.standard)
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
            .foregroundColor(.ds.text.neutral.catchy)
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
      Button(L10n.Core.chooseServiceAddDetails) {
        self.viewModel.completion(self.viewModel.searchCriteria)
      }
      .foregroundColor(.ds.text.brand.standard)
      .frame(maxWidth: .infinity)
    }
  }

  struct ChooseWebsiteView_Previews: PreviewProvider {
    static var previews: some View {
      MultiContextPreview(dynamicTypePreview: false) {
        Group {
          NavigationView {
            ChooseWebsiteView(viewModel: .mock())
          }
          NavigationView {
            ChooseWebsiteView(viewModel: .mock(includeSearchedWebsites: true))
          }
        }
      }
    }
  }
#endif
