import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension FiscalInformation: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .fiscalInformation(self)
  }

  public var localizedTitle: String {
    L10n.Core.kwFiscalStatementIOS
  }

  public var localizedSubtitle: String {
    return fiscalNumber
  }

  public static var localizedName: String {
    L10n.Core.kwFiscalStatementIOS
  }

  public static var addTitle: String {
    L10n.Core.kwadddatakwFiscalStatementIOS
  }

  public static var nativeMenuAddTitle: String {
    L10n.Core.addTaxNumber
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
