import CorePersonalData
import DesignSystem
import IconLibrary
import SwiftUI
import UIDelight
import VaultKit

struct DarkWebMonitoringBreachView<Model: BreachViewModel>: View {

  let model: Model

  var body: some View {
    HStack(spacing: 16) {
      BreachIconView(model: model.iconViewModel)
      VStack(alignment: .leading, spacing: 2) {
        website
        info
      }
    }
    .listRowInsets(EdgeInsets())
    .padding(.leading, 16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(height: 61)
    .background(Color.ds.container.agnostic.neutral.supershy)
  }

  @ViewBuilder
  private var website: some View {
    HStack(spacing: 0) {
      Group {
        if !model.hasBeenViewed {
          Circle()
            .foregroundColor(.ds.text.danger.quiet)
            .frame(width: 8, height: 9)
            .padding(4)
        }
        if model.url.displayDomain.isEmpty {
          Text(L10n.Localizable.darkWebMonitoringBreachViewDomainPlaceholder).fontWeight(
            model.hasBeenViewed ? .regular : .bold)
        } else {
          Text(model.url.displayDomain.capitalizingFirstLetter()).fontWeight(
            model.hasBeenViewed ? .regular : .bold)
        }
      }
      .font(.body)
      .foregroundColor(.ds.text.neutral.catchy)
      .lineLimit(1)
    }
  }

  @ViewBuilder
  private var info: some View {
    Text(model.displayDate)
      .foregroundColor(.ds.text.danger.standard)
  }
}

struct DarkWebMonitoringBreachView_Previews: PreviewProvider {
  static var breachNewAlert: BreachViewModel {
    return BreachViewModel.mock(
      for: DWMSimplifiedBreach(
        breachId: UUID().uuidString, url: PersonalDataURL(rawValue: "_"), leakedPassword: nil,
        date: Date()), hasBeenAddressed: false)
  }

  static var breachAlertWithDate: BreachViewModel {
    return BreachViewModel.mock(
      for: DWMSimplifiedBreach(
        breachId: UUID().uuidString, url: PersonalDataURL(rawValue: "_"), leakedPassword: nil,
        date: Date()), hasBeenAddressed: true)
  }

  static var breachAlertWithoutDate: BreachViewModel {
    return BreachViewModel.mock(
      for: DWMSimplifiedBreach(
        breachId: UUID().uuidString, url: PersonalDataURL(rawValue: "_"), leakedPassword: nil,
        date: nil), hasBeenAddressed: true)
  }

  static var breachAlertNonUniqueOne: BreachViewModel {
    return BreachViewModel.mock(
      for: DWMSimplifiedBreach(
        breachId: UUID().uuidString, url: PersonalDataURL(rawValue: "_"), leakedPassword: nil,
        date: Date(), email: "_"), hasBeenAddressed: true)
  }

  static var breachAlertNonUniqueTwo: BreachViewModel {
    return BreachViewModel.mock(
      for: DWMSimplifiedBreach(
        breachId: UUID().uuidString, url: PersonalDataURL(rawValue: "_"), leakedPassword: nil,
        date: Date(), email: "_"), hasBeenAddressed: true)
  }

  static var breachUnknownWebsite: BreachViewModel {
    return BreachViewModel.mock(
      for: DWMSimplifiedBreach(
        breachId: UUID().uuidString, url: PersonalDataURL(rawValue: ""), leakedPassword: nil,
        date: nil), hasBeenAddressed: true)
  }

  static var previews: some View {
    MultiContextPreview {
      List {
        DarkWebMonitoringBreachView(model: breachNewAlert)
        DarkWebMonitoringBreachView(model: breachAlertWithDate)
        DarkWebMonitoringBreachView(model: breachAlertWithoutDate)
        DarkWebMonitoringBreachView(model: breachAlertNonUniqueOne)
        DarkWebMonitoringBreachView(model: breachAlertNonUniqueTwo)
        DarkWebMonitoringBreachView(model: breachUnknownWebsite)
      }
    }
  }
}

extension Credential {
  fileprivate init(url: PersonalDataURL) {
    self.init()
    self.url = url
  }
}
