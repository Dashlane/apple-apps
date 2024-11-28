import CorePersonalData
import DesignSystem
import IconLibrary
import SwiftTreats
import SwiftUI

extension View {
  @ViewBuilder
  public func draggableItem(_ item: VaultItem) -> some View {
    if Device.isIpadOrMac, let transferableItem = item as? Credential {
      self.draggable(transferableItem) {
        DraggableView(item: item)
      }
    } else {
      self
    }
  }
}

private struct DraggableView: View {
  let item: VaultItem

  var body: some View {
    if let draggableIcon = draggableIcon {
      VStack {
        draggableIcon
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
          .compositingGroup()

        Text(item.localizedTitle)
          .textStyle(.body.standard.strong)
          .foregroundStyle(Color.ds.text.neutral.standard)
      }
      .padding(4)
      .background(Color.clear)
    }
  }

  var draggableIcon: SwiftUI.Image? {
    switch item.enumerated {
    case .credential:
      return .ds.item.login.outlined
    default:
      return nil
    }
  }
}

extension View {
  @ViewBuilder
  public func droppableDestination<T: TransferablePersonalData>(
    for payloadType: T.Type = T.self,
    action: @escaping (_ items: [T], _ location: CGPoint) -> Bool,
    isTargeted: @escaping (Bool) -> Void = { _ in }
  ) -> some View {
    if Device.isIpadOrMac {
      self.dropDestination(for: payloadType, action: action, isTargeted: isTargeted)
    } else {
      self
    }
  }
}
