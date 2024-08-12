import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

public struct DuplicateItemsView: View {
  @Environment(\.dismiss) private var dismiss

  @StateObject
  var viewModel: DuplicateItemsViewModel

  public init(viewModel: @autoclosure @escaping () -> DuplicateItemsViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  public var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        switch viewModel.state {
        case .loading:
          ProgressViewBox()
            .tint(.ds.text.brand.standard)
        case .foundDuplicates(let items):
          VStack {
            Text(
              "These are duplicate items found in your vault, their originals will not be removed."
            )
            .textStyle(.body.standard.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)

            List(items, id: \.id) { item in
              let userSpace = viewModel.userSpacesConfiguration.displayedUserSpace(for: item)

              VaultItemRow(
                item: item,
                userSpace: userSpace,
                vaultIconViewModelFactory: viewModel.vaultItemIconViewModelFactory)
            }
            .listStyle(.plain)

            Button("Remove") {
              viewModel.confirmDeduplication(for: items)
              dismiss()
            }
            .buttonStyle(.designSystem(.titleOnly))
          }
        case .noDuplicates:
          Text("No duplicates found")
        }
      }
      .padding()
      .navigationTitle("Duplicate items")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(CoreLocalization.L10n.Core.cancel) {
            dismiss()
          }
        }
      }
    }

  }
}

#Preview {
  DuplicateItemsView(viewModel: .mock())
}
