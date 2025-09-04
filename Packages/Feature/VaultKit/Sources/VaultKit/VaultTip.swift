import DesignSystem
import TipKit

public enum VaultTip: View {
  case itemDragAndDrop

  public var body: some View {
    switch self {
    case .itemDragAndDrop:
      TipView(VaultItemDragDropTip())
        .tipBackground(Color.ds.container.agnostic.neutral.standard)
    }
  }
}
