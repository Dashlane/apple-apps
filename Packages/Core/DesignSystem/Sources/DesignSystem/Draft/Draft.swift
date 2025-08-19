import SwiftUI

extension DS {
  public enum Draft {}
}

public struct DraftLibrary: LibraryContentProvider {
  public var views: [LibraryItem] {
    []
  }
}
