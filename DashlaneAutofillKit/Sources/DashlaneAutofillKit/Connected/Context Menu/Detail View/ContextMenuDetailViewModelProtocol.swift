import CorePersonalData
import CoreTypes
import Foundation
import SwiftUI
import VaultKit

public protocol ContextMenuDetailViewModelProtocol: ObservableObject {
  associatedtype Item: VaultItem, Equatable
  var service: DetailServiceContextMenuAutofill<Item> { get }
  var completion: (VaultItem, String) -> Void { get }
}

extension ContextMenuDetailViewModelProtocol {

  public var item: Item {
    get {
      service.item
    }
    set {
      service.item = newValue
    }
  }

  public func performAutofill(with text: String) {
    completion(item, text)
  }

}
