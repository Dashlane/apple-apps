import DesignSystem
import SwiftUI

struct DataLeakMonitoringAddEmailSuccessView: View {

  var dismiss: DismissAction

  let monitoredEmail: String

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Image.ds.item.email.outlined
        .resizable()
        .frame(width: 64, height: 64)
        .foregroundStyle(Color.ds.text.brand.quiet)
        .accessibilityHidden(true)
      Text(L10n.Localizable.dataleakmonitoringSuccessTitle)
        .font(.title2)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .bold()
      Text(L10n.Localizable.dataleakmonitoringSuccessDescription(monitoredEmail))
        .foregroundStyle(Color.ds.text.neutral.standard)
      Spacer()
      closeButton
    }
    .navigationBarHidden(true)
    .padding(.top, 40)
    .padding()
  }

  var closeButton: some View {
    Button(L10n.Localizable.dataleakmonitoringSuccessCloseButton) {
      dismiss()
    }
    .buttonStyle(.designSystem(.titleOnly))
  }
}

struct DataLeakMonitoringAddEmailSuccessView_Previews: PreviewProvider {

  @Environment(\.dismiss)
  static var dismiss

  static var previews: some View {
    DataLeakMonitoringAddEmailSuccessView(
      dismiss: dismiss,
      monitoredEmail: "_")
  }
}
