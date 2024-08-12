import CoreLocalization
import CoreSession
import DashTypes
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct DeviceTransferTypeSelectionView: View {
  let login: Login
  let completion: (DeviceTransferLoginFlowStateMachine.Event) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      Text(L10n.Core.Mpless.D2d.Untrusted.chooseTypeTitle)
        .font(.title)
        .foregroundColor(.ds.text.neutral.catchy)

      VStack(spacing: 12) {
        button(
          title: L10n.Core.Mpless.D2d.Untrusted.chooseTypeComputerCta,
          image: Image.ds.laptop.outlined
        ) {
          completion(.startSecurityChallengeFlow(login))
        }
        button(
          title: L10n.Core.Mpless.D2d.Untrusted.chooseTypeMobileCta,
          image: Image.ds.item.phoneMobile.outlined
        ) {
          completion(.startQRCodeFlow)
        }
      }
      Spacer()
      Button(L10n.Core.Mpless.D2d.Untrusted.chooseTypeNoDeviceCta) {
        completion(.startRecovery(login))
      }
      .style(mood: .brand, intensity: .quiet)
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
    .background(Color.ds.background.alternate)
    .navigationTitle(L10n.Core.deviceToDeviceNavigationTitle)
    .loginAppearance()
    .reportPageAppearance(.loginDeviceTransfer)
  }

  func button(title: String, image: Image, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        image
        Text(title)
        Spacer()
        Image(systemName: "chevron.right")
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(Color.ds.container.agnostic.neutral.supershy)
      )
    }
    .foregroundColor(.ds.text.neutral.catchy)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationView {
    DeviceTransferTypeSelectionView(login: Login("_")) { _ in }
  }
}
