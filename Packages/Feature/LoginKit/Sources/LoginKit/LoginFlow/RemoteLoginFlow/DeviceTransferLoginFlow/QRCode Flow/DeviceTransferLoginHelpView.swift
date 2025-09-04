import CoreLocalization
import Foundation
import SwiftUI
import UIComponents
import UIDelight

public struct DeviceTransferLoginHelpView: View {

  @Environment(\.dismiss)
  var dismiss

  public var body: some View {
    NavigationView {
      ViewThatFits {
        ScrollView {
          mainView
        }
        mainView
      }
      .background(.ds.background.alternate.ignoresSafeArea())
      .navigationTitle(CoreL10n.deviceToDeviceNavigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(
            action: {
              dismiss()
            },
            label: {
              Text(CoreL10n.kwButtonClose)
            }
          )
          .foregroundStyle(Color.ds.text.brand.standard)
        }
      }
    }
  }

  private var mainView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(CoreL10n.deviceToDeviceHelpTitle)
        .textStyle(.title.section.large)
        .padding(.bottom, 24)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(CoreL10n.deviceToDeviceHelpSubtitle1)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .textStyle(.title.section.medium)

      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          Text("1. ")
          Text(CoreL10n.deviceToDeviceHelpMessage1)
        }
        .foregroundStyle(Color.ds.text.neutral.standard)
        HStack(alignment: .top) {
          Text("2. ")
          MarkdownText(CoreL10n.deviceToDeviceHelpMessage2)
        }
        .foregroundStyle(Color.ds.text.neutral.standard)

      }
      .textStyle(.body.standard.regular)

      Divider()
        .padding(.vertical, 16)
      Text(CoreL10n.deviceToDeviceHelpSubtitle2)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .textStyle(.title.section.medium)
      Text(CoreL10n.deviceToDeviceHelpMessage3)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
      Spacer()
    }
    .padding(24)
  }
}

struct DeviceToDeviceLoginHelpView_Previews: PreviewProvider {
  static var previews: some View {
    DeviceTransferLoginHelpView()
  }
}
