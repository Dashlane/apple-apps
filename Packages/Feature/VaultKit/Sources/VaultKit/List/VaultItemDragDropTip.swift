import CoreFeature
import CoreLocalization
import DesignSystem
import TipKit

public struct VaultItemDragDropTip: Tip {

  public static let dragAndDropEvent: Event = Event(id: "itemDragAndDrop")
  static let collectionCreationEvent: Event = Event(id: "created_collection")

  public var title: Text {
    Text("Drag & Drop items")
      .foregroundStyle(Color.ds.text.neutral.catchy)
  }

  public var message: Text? {
    Text("You can now drag & drop items into a collection located in the sidebar")
      .foregroundStyle(Color.ds.text.neutral.quiet)
  }

  public var image: Image? {
    Image(systemName: "hand.draw")
  }

  public var rules: [Rule] {
    #Rule(Self.collectionCreationEvent) { $0.donations.count >= 1 }
    #Rule(Self.dragAndDropEvent) { $0.donations.count == 0 }
  }

  public var options: [TipOption] {
    [
      IgnoresDisplayFrequency(true),
      MaxDisplayCount(1),
    ]
  }
}
