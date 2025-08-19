import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension FiscalInformation: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .fiscalInformation(self)
  }

  public var localizedTitle: String {
    CoreL10n.kwFiscalStatementIOS
  }

  public var localizedSubtitle: String {
    return fiscalNumber
  }

  public static var localizedName: String {
    CoreL10n.kwFiscalStatementIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwFiscalStatementIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addTaxNumber
  }
}

extension FiscalInformation: CopiablePersonalData {
  public var valueToCopy: String {
    return fiscalNumber
  }

  public var fieldToCopy: DetailFieldType {
    return .fiscalNumber
  }
}
