import DesignSystem
import SwiftUI
import Combine
import UIDelight

struct ToolsView: View {

    @StateObject
    var viewModel: ToolsViewModel

        @State
    private var tallestCell: CGFloat = 112

    @State
    private var columns: [GridItem] = [GridItem.toolsColumn(), GridItem.toolsColumn()] {
        didSet {
                        tallestCell = 112
        }
    }

    init(viewModel: @autoclosure @escaping () -> ToolsViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        list
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .navigationTitle(L10n.Localizable.toolsTitle)
            .reportPageAppearance(.tools)
    }

    private var list: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(viewModel.tools) { tool in
                    Button {
                        viewModel.didSelect(tool.item)
                    } label: {
                        ToolGridCell(tool: tool)
                            .frame(minHeight: tallestCell)
                            .onSizeChange { size in 
                                onCellSizeChange(size, currentColumnsCount: columns.count)
                            }
                    }
                }
            }
            .padding(16)
        }
    }

    private func onCellSizeChange(_ size: CGSize, currentColumnsCount: Int) {
                                guard size.height > tallestCell,
              currentColumnsCount == columns.count,
              columns.count > 1 else {
            return
        }
        if columns.count == 2 && size.height > 160 {
            self.columns = [GridItem.toolsColumn()]
        } else {
            self.tallestCell = size.height
        }
    }

}

private extension GridItem {
    static func toolsColumn() -> GridItem {
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
