import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

public struct URLLinkDetailField: DetailField {
  @Environment(\.openURL) private var openURL

  let personalDataURL: PersonalDataURL

  var canOpen: Bool {
    personalDataURL.openableURL != nil
  }

  var onOpenURL: (() -> Void)

  public init(personalDataURL: PersonalDataURL, onOpenURL: @escaping () -> Void) {
    self.personalDataURL = personalDataURL
    self.onOpenURL = onOpenURL
  }

  @ViewBuilder
  public var body: some View {
    personalDataURL.openableURL.map { url in
      DS.TextField(
        "",
        text: .constant("\(personalDataURL.displayedScheme)\(personalDataURL.displayDomain)"),
        actions: {
          if canOpen {
            DS.FieldAction.Button(
              L10n.Core.openWebsite,
              image: .ds.action.openExternalLink.outlined
            ) {
              openURL(url)
              onOpenURL()
            }
          }
        }
      )
      .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
      .editionDisabled()
      .fieldLabelPersistencyDisabled()
      .textColorHighlightingMode(.url)
    }
  }
}

#Preview {
  URLLinkDetailField(personalDataURL: PersonalDataURL(rawValue: "_"), onOpenURL: {})
}
