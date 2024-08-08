import Foundation
import SwiftUI

public enum HomeListElementPriority: Double {
  case bottomAnnouncement = 0
  case list
  case indexedList
  case header
}

extension View {
  public func accessibilitySortPriority(_ priority: HomeListElementPriority) -> some View {
    self.accessibilitySortPriority(priority.rawValue)
  }
}
