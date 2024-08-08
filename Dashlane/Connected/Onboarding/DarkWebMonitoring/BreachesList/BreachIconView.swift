import IconLibrary
import SwiftUI
import VaultKit

struct BreachIconView: View {

  let model: DWMItemIconViewModelProtocol
  var iconSize: IconSizeType

  init(model: DWMItemIconViewModelProtocol, iconSize: IconSizeType = .small) {
    self.model = model
    self.iconSize = iconSize
  }

  @ViewBuilder
  var body: some View {
    DomainIconView(
      model: model.makeDomainIconViewModel(size: iconSize),
      placeholderTitle: model.url.displayDomain)
  }
}
