import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI

struct DetailDebugInfoSection: View {

  private let item: VaultItem

  @State
  private var isDebugInfoShown: Bool = false

  init(item: VaultItem) {
    self.item = item
  }

  var body: some View {
    Section {
      Button {
        isDebugInfoShown = true
      } label: {
        Text(CoreL10n.debugInfoTitle)
      }
      .buttonStyle(DetailRowButtonStyle())
    }
    .sheet(isPresented: $isDebugInfoShown) {
      DetailDebugInfoView(item: item, isDebugInfoShown: $isDebugInfoShown)
        .toasterOn()
    }
  }

}

struct DetailDebugInfoSection_Previews: PreviewProvider {
  static var previews: some View {
    DetailDebugInfoSection(item: .mockPendingSync(creationDate: .now))
  }
}
