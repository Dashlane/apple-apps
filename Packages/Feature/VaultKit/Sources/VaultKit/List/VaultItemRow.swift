import CoreLocalization
import CorePersonalData
import CorePremium
import DesignSystem
import SwiftUI
import UIDelight

public struct VaultItemRow: View {
  @Environment(\.highlightedValue) private var highlightedValue
  @Environment(\.vaultItemRowShowSharingInfo) var showSharingInfo
  @Environment(\.toast) private var toast

  @ScaledMetric private var sharedIconSize: CGFloat = 12
  @State var showLimitedRightsAlert: Bool = false

  private let item: VaultItem
  private let space: UserSpace?
  private let vaultIconViewModelFactory: VaultItemIconViewModel.Factory

  public init(
    item: VaultItem,
    userSpace: UserSpace?,
    vaultIconViewModelFactory: VaultItemIconViewModel.Factory
  ) {
    self.item = item
    self.space = userSpace
    self.vaultIconViewModelFactory = vaultIconViewModelFactory
  }

  public var body: some View {
    DS.ListItemContentView {
      DS.ListItemLabel {
        DS.ListItemLabelTitle(item.localizedTitle) {
          if let space = space {
            UserSpaceIcon(space: space, size: .small)
              .equatable()
          }
          if showSharingInfo, item.metadata.isShared {
            Image.ds.shared.outlined
              .resizable()
          }
          if item is Passkey {
            Image.ds.passkey.outlined
              .resizable()
          }
        }
      } description: {
        DS.ListItemLabelDescription(descriptionValue, icon: item.subtitleImage)
      }
    } leadingAccessory: {
      icon
    }
  }

  private var icon: some View {
    VaultItemIconView(
      isListStyle: true,
      model: vaultIconViewModelFactory.make(item: item)
    )
    .equatable()
    .accessibilityHidden(true)
  }

  private var descriptionValue: String {
    if let highlightedValue,
      let result = item.matchCriteria(highlightedValue),
      case let .secondaryInfo(value) = result.location
    {
      let sanitizedString = value.replacingOccurrences(of: "\n", with: " ")
      if let range = value.range(
        of: highlightedValue, options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive]),
        (value[..<range.lowerBound].count + highlightedValue.count) > 30
      {
        return "..." + value[range.lowerBound...]
      } else {
        return sanitizedString
      }

    } else {
      return item.localizedSubtitle
    }
  }
}

#if DEBUG
  extension VaultItemRow {
    fileprivate init(item: VaultItem, space: UserSpace? = nil) {
      self.item = item
      self.space = space
      self.vaultIconViewModelFactory = .init({ VaultItemIconViewModel.mock(item: $0) })
    }

    static func mock(item: VaultItem, space: UserSpace? = nil) -> VaultItemRow {
      return VaultItemRow(item: item, space: space)
    }
  }

  #Preview("Credentials") {
    List {
      VaultItemRow(item: PersonalDataMock.Credentials.instagram)
      VaultItemRow(item: PersonalDataMock.Addresses.home)
      VaultItemRow(item: PersonalDataMock.SecureNotes.thinkDifferent)
      VaultItemRow(item: PersonalDataMock.Identities.personal)
      VaultItemRow(item: PersonalDataMock.Phones.personal)
      VaultItemRow(item: PersonalDataMock.Companies.dashlane)
      VaultItemRow(item: PersonalDataMock.PersonalWebsites.blog)
      VaultItemRow(item: PersonalDataMock.DrivingLicences.personal)
      VaultItemRow(item: PersonalDataMock.SocialSecurityInformations.us)
      VaultItemRow(item: PersonalDataMock.SocialSecurityInformations.gb)
      VaultItemRow(item: PersonalDataMock.SocialSecurityInformations.ru)
      VaultItemRow(item: PersonalDataMock.IDCards.personal)
      VaultItemRow(item: PersonalDataMock.Passports.personal)
      VaultItemRow(item: PersonalDataMock.BankAccounts.personal)
    }
  }

  #Preview("Passkey") {
    List {
      VaultItemRow(item: Passkey.github)
    }
  }

  #Preview("Credit Cards") {
    List(CreditCardColor.allCases, id: \.self) { color in
      VaultItemRow(item: PersonalDataMock.CreditCards.creditCard(withColor: color))
    }
  }
#endif
