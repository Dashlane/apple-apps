import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension DrivingLicence {
  public var listIcon: VaultItemIcon {
    .drivingLicense
  }

  public var icon: VaultItemIcon {
    .drivingLicense
  }

  private var backgroundColor: SwiftUI.Color? {
    DrivingLicenceColor(countryCode: country?.code, state: state?.code).color
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.driversLicense.outlined
  }
}

extension DrivingLicenceColor {
  var color: Color? {
    switch self {
    case .newYork:
      return Color(asset: Asset.drivingLicenceNewYork)
    case .california:
      return Color(asset: Asset.drivingLicenceCalifornia)
    case .restOfTheUS, .restOfTheWorld:
      return nil
    }
  }
}
