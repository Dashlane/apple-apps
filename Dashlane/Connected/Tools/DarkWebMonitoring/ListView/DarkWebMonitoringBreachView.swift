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
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.ds.container.agnostic.neutral.supershy)
    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
  }

  @ViewBuilder
  private var website: some View {
    HStack(spacing: 0) {
      Group {
        if !model.hasBeenViewed {
          Circle()
            .foregroundStyle(Color.ds.text.danger.quiet)
            .frame(width: 8, height: 8)
            .padding(4)
        }
        if model.url.displayDomain.isEmpty {
          Text(L10n.Localizable.darkWebMonitoringBreachViewDomainPlaceholder).fontWeight(
            model.hasBeenViewed ? .regular : .medium)
        } else {
          Text(model.url.displayDomain.capitalizingFirstLetter()).fontWeight(
            model.hasBeenViewed ? .regular : .medium)
        }
      }
      .textStyle(.body.standard.regular)
      .foregroundStyle(Color.ds.text.neutral.catchy)
      .lineLimit(1)
    }
  }

  @ViewBuilder
  private var info: some View {
    Text(model.displayDate)
      .foregroundStyle(Color.ds.text.danger.standard)
      .textStyle(.body.reduced.regular)
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
      }.listStyle(.ds.insetGrouped)
    }
  }
}

extension Credential {
  fileprivate init(url: PersonalDataURL) {
    self.init()
    self.url = url
  }
}
