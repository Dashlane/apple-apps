import IconLibrary
import SwiftUI
import VaultKit

struct BreachIconView: View {
  let model: DWMItemIconViewModelProtocol

  init(model: DWMItemIconViewModelProtocol) {
    self.model = model
  }

  @ViewBuilder
  var body: some View {
    DomainIconView(model: model.makeDomainIconViewModel())
  }
}
