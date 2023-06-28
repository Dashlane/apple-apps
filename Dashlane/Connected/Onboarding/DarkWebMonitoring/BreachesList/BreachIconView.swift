import SwiftUI
import VaultKit
import IconLibrary

struct BreachIconView: View {

    let model: DWMItemIconViewModelProtocol
    var iconSize: IconStyle.SizeType

    init(model: DWMItemIconViewModelProtocol, iconSize: IconStyle.SizeType = .small) {
        self.model = model
        self.iconSize = iconSize
    }

    @ViewBuilder
    var body: some View {
        DomainIconView(model: model.makeDomainIconViewModel(size: iconSize),
                            placeholderTitle: model.url.displayDomain)
    }
}
