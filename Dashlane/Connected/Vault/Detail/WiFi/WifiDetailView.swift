import CoreFeature
import CoreLocalization
import CorePersonalData
import SwiftUI
import UIComponents
import VaultKit

public struct WifiDetailView: View {
  @StateObject var model: WifiDetailViewModel

  public init(model: @escaping @autoclosure () -> WifiDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        networkName

        passwordField

        noteField

        if !model.mode.isEditing {
          qrCodeField

          #if HOTSPOT_ENTITLED
            connectionField
          #endif
        }
      }

      Section {
        itemNameField
      } header: {
        Text(CoreL10n.WiFi.DetailView.organization)
          .foregroundStyle(Color.ds.text.neutral.quiet)
      }
    }
    .makeShortcuts(model: model)

  }

  private var networkName: some View {
    TextDetailField(
      title: CoreL10n.WiFi.DetailView.ssid,
      text: $model.item.ssid,
      placeholder: ""
    )
    .fieldRequired()
  }

  private var passwordField: some View {
    SecureDetailField(
      title: CoreL10n.WiFi.DetailView.password,
      text: $model.item.passphrase,
      onRevealAction: model.sendUsageLog,
      actions: [.copy(model.copy)]
    )
    .actions([.copy(model.copy)])
  }

  private var noteField: some View {
    NotesDetailField(
      title: CoreL10n.WiFi.DetailView.note,
      text: $model.item.note

    )
    .actions([.copy(model.copy)], hasAccessory: false)
  }

  private var itemNameField: some View {
    TextDetailField(
      title: CoreL10n.WiFi.DetailView.itemName,
      text: $model.item.name,
      placeholder: ""
    )
  }

  private var qrCodeField: some View {
    RowButton(CoreL10n.WiFi.DetailView.viewQRCode) {
      model.showQRCodeView()
    } accessory: {
      Image.ds.qrCode.outlined
    }
    .sheet(isPresented: $model.showQRCodeSheet) {
      WifiQRCodeView(model: model.makeWifiQRCodeViewModel())
    }
  }

  @ViewBuilder
  private var connectionField: some View {
    RowButton(CoreL10n.WiFi.connectCTA, action: model.connect) {
      if model.isConnecting {
        ProgressView()
          .progressViewStyle(.indeterminate)
      } else {
        Image.ds.item.wifi.outlined
      }
    }
    .disabled(model.isConnecting)
  }

  private struct RowButton<T: View>: View {
    private let title: String
    private let action: () -> Void
    private let accessory: T

    init(
      _ title: String,
      action: @escaping () -> Void,
      @ViewBuilder accessory: () -> T
    ) {
      self.title = title
      self.action = action
      self.accessory = accessory()
    }

    var body: some View {
      HStack {
        Button(title, action: action)
          .frame(maxWidth: .infinity, alignment: .leading)
          .fontWeight(.medium)

        accessory
          .foregroundStyle(Color.ds.text.brand.standard)
      }
    }
  }
}

extension View {
  fileprivate func makeShortcuts(model: WifiDetailViewModel) -> some View {
    self.mainMenuShortcut(
      .copyPrimary(title: CoreL10n.WiFi.copyActionCTA),
      enabled: !model.mode.isEditing && !model.item.ssid.isEmpty,
      action: {
        model.copy(model.item.ssid, fieldType: .password)
      })
  }
}

#Preview {
  WifiDetailView(
    model: MockVaultConnectedContainer().makeWifiDetailViewModel(
      item: WiFi(ssid: "Dashlane Office Wi-Fi", encryptionType: .wpa3Personal, passphrase: "_")))
}
