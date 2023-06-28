#if canImport(UIKit)
import Foundation
import SwiftUI
import CoreLocalization
import UIComponents
import UIDelight

public struct DeviceToDeviceLoginHelpView: View {

    @Environment(\.dismiss)
    var dismiss

    public var body: some View {
        NavigationView {
            FullScreenScrollView {
                mainView
                    .padding(24)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                dismiss()
                            }, label: {
                                Text(L10n.Core.kwButtonClose)
                            })
                            .foregroundColor(.ds.text.brand.standard)
                        }
                    }
            }.background(.ds.background.alternate.ignoresSafeArea())
                .navigationBarStyle(.transparent)
                .navigationTitle(L10n.Core.deviceToDeviceNavigationTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Core.deviceToDeviceHelpTitle)
                .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
                .padding(.bottom, 24)
                .foregroundColor(.ds.text.neutral.catchy)
            Text(L10n.Core.deviceToDeviceHelpSubtitle1)
                .foregroundColor(.ds.text.neutral.catchy)
                .font(.custom(GTWalsheimPro.bold.name, size: 20, relativeTo: .title).weight(.medium))

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("1. ")
                    Text(L10n.Core.deviceToDeviceHelpMessage1)
                        .font(.body)
                }
                .foregroundColor(.ds.text.neutral.standard)
                HStack(alignment: .top) {
                    Text("2. ")
                    MarkdownText(L10n.Core.deviceToDeviceHelpMessage2)
                        .font(.body)
                }
                .foregroundColor(.ds.text.neutral.standard)

            }
            Divider()
                .padding(.vertical, 16)
            Text(L10n.Core.deviceToDeviceHelpSubtitle2)
                .foregroundColor(.ds.text.neutral.catchy)
                .font(.custom(GTWalsheimPro.bold.name, size: 20, relativeTo: .title).weight(.medium))
            Text(L10n.Core.deviceToDeviceHelpMessage3)
                .font(.body)
                .foregroundColor(.ds.text.neutral.standard)
            Spacer()
        }
    }
}

struct DeviceToDeviceLoginHelpView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceToDeviceLoginHelpView()
    }
}
#endif
