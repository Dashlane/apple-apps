import DesignSystemExtra
import SecurityDashboard
import SwiftUI
import UIDelight

@ViewInit
struct BreachPopupAlertModifier: ViewModifier {
  @StateObject var model: BreachPopupAlertModifierModel

  func body(content: Content) -> some View {
    content
      .background {
        Color.clear
          .fullScreenCover(item: $model.breachAlert) { breachAlert in
            Group {
              switch breachAlert {
              case .single(let popupAlert):
                SingleBreachAlert(popupAlert: popupAlert) { action in
                  model.handleAction(for: action, on: popupAlert)
                }
              case .grouped(let ids):
                multipleAlert(forIds: ids)
              }
            }
            .presentationBackground(Color.black.opacity(0.5))
          }
          .transaction({ transaction in transaction.disablesAnimations = true })
      }

  }

  @ViewBuilder
  func multipleAlert(forIds ids: [String]) -> some View {
    NativeAlert {
      VStack {
        Text(L10n.Localizable.securityBreachMultipleAlertTitle)
          .font(.body.bold())

        Text(L10n.Localizable.groupedAlertMessage(forBreachesCount: ids.count))
      }.padding(16)
    } buttons: {
      Button(L10n.Localizable.securityBreachMultipleAlertCloseCta, role: .cancel) {
        model.updateBreachesStatus(for: ids, to: .viewed)
      }

      Button(L10n.Localizable.securityBreachMultipleAlertViewCta) {
        model.updateBreachesStatus(for: ids, to: .viewed)
        model.showDarkWebMonitoringSection()
      }
    }
  }
}

extension L10n.Localizable {
  fileprivate static func groupedAlertMessage(forBreachesCount count: Int) -> AttributedString {
    var message = AttributedString(L10n.Localizable.securityBreachMultipleAlertDescription(count))
    if let range = message.range(of: "\(count)") {
      message[range].foregroundColor = Color.ds.text.brand.standard
    }

    return message
  }
}
