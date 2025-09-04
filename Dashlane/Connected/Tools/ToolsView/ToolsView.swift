import Combine
import DesignSystem
import SwiftUI
import UIDelight

struct ToolsView: View {

  @StateObject
  var viewModel: ToolsViewModel

  @ScaledMetric(relativeTo: .body)
  private var cellHeight: CGFloat = 132

  @Environment(\.sizeCategory)
  var sizeCategory

  init(viewModel: @autoclosure @escaping () -> ToolsViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    list
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .navigationTitle(L10n.Localizable.toolsTitle)
      .reportPageAppearance(.tools)
  }

  private var list: some View {
    ScrollView {
      if sizeCategory > .extraExtraLarge {
        VStack {
          cells(withMinHeight: nil)
        }
        .padding(16)
      } else {
        LazyVGrid(columns: [GridItem.toolsColumn(), GridItem.toolsColumn()], spacing: 15) {
          cells(withMinHeight: cellHeight)
        }.padding(16)
      }
    }
    .scrollContentBackgroundStyle(.alternate)
  }

  @ViewBuilder
  func cells(withMinHeight minHeight: CGFloat?) -> some View {
    ForEach(viewModel.tools) { tool in
      Button {
        viewModel.didSelect(tool.item)
      } label: {
        ToolGridCell(tool: tool)
          .frame(minHeight: minHeight)

      }
    }
  }

}

extension GridItem {
  fileprivate static func toolsColumn() -> GridItem {
    GridItem(.flexible(), spacing: 15)
  }
}

struct ToolsView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(dynamicTypePreview: true) {
      NavigationView {
        ToolsView(viewModel: ToolsViewModel.mock)
      }
    }
  }
}
