import CoreLocalization
import CoreSession
import DashlaneAPI
import DesignSystem
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct DevicesList: View {
  enum DeletionRequest: Identifiable {
    case singleItem(BucketDevice)
    case multipleItems([BucketDevice])

    var id: String {
      switch self {
      case .singleItem:
        return "single"
      case .multipleItems:
        return "multiple"
      }
    }
  }

  @Environment(\.editMode) var mode

  @ObservedObject var model: DeviceListViewModel

  @State private var selectedDevice: BucketDevice?
  @State private var deviceToBeRenamed: BucketDevice?
  @State private var deletionRequest: DeletionRequest?
  @State private var showConfirmationDialog = false
  @State private var selectedDevices = Set<String>()

  @ViewBuilder
  var body: some View {
    ZStack {
      Spacer()
        .alert(
          L10n.Localizable.kwDeviceDeactivateFailureTitle,
          isPresented: $model.isDeactivationFailed,
          actions: {
            Button(CoreL10n.kwButtonOk) {}
          },
          message: {
            Text(L10n.Localizable.kwDeviceDeactivateFailureMsg)
          }
        )

      list
        .fullScreenCover(item: self.$deviceToBeRenamed, content: self.renameView)
        .actionSheet(item: self.$selectedDevice, content: self.mainActionSheet)
        .alert(item: self.$deletionRequest, content: self.deactivateAlert)
        .toolbar(mode?.wrappedValue != .active ? .hidden : .visible, for: .bottomBar)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }

          ToolbarItemGroup(placement: .bottomBar) {
            bottomBar
          }
        }

      if model.listStatus == .loading {
        loadingIndicator
      } else if model.listStatus == .noInternet {
        listErrorPlaceholder(withMessage: CoreL10n.kwNoInternet)
      } else if model.listStatus == .error {
        listErrorPlaceholder(withMessage: CoreL10n.kwExtSomethingWentWrong)
      }
    }.animation(.default, value: model.devicesGroups)
      .navigationBarBackButtonHidden(mode?.wrappedValue == .active)
  }

  @ViewBuilder
  var bottomBar: some View {
    Menu {
      Button(L10n.Localizable.kwDeviceListToolbarUnselectAll) {
        self.selectedDevices = []
      }
      .disabled(selectedDevices.isEmpty)
      Button(L10n.Localizable.kwDeviceListToolbarSelectOthers) {
        self.selectedDevices = model.allDevicesIdsButCurrentOne()
      }
      Button(L10n.Localizable.kwDeviceListToolbarSelectAll) {
        self.selectedDevices = model.allDevicesIds()
      }
    } label: {
      Image(systemName: "ellipsis.circle")
    }
    Spacer()
    Text(L10n.Localizable.kwDeviceListToolbarTitle)
      .bold()
      .foregroundStyle(Color.ds.text.neutral.standard)
    Spacer()
    Button(
      action: {
        let devices = model.devices(forIds: self.selectedDevices)
        if devices.count == 1, let device = devices.first {
          self.deletionRequest = .singleItem(device)
          self.showConfirmationDialog = true
        } else {
          self.deletionRequest = .multipleItems(devices)
          self.showConfirmationDialog = true
        }
      },
      label: {
        Image(systemName: "trash")
          .foregroundStyle(Color.ds.text.danger.standard)
      }
    ).disabled(self.selectedDevices.isEmpty)
  }

  var list: some View {
    List(selection: $selectedDevices) {
      ForEach(model.devicesGroups) { devices in
        Section(devices.dateGroup.localizedDeviceTitle) {
          ForEach(devices.devices) { device in
            BucketDeviceRow(device: device, isCurrent: model.currentDeviceId == device.id)
              .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
              .padding(6)
              .onTapGesture {
                if mode?.wrappedValue != .active {
                  self.selectedDevice = device
                }
              }

          }
        }
      }
    }
    .listStyle(.ds.insetGrouped)
    .headerProminence(.increased)
    .navigationTitle(L10n.Localizable.kwDeviceListTitle)
    .reportPageAppearance(.settingsDeviceList)
  }

  private var loadingIndicator: some View {
    IndeterminateCircularProgress()
      .frame(width: 30, height: 30)
  }

  private func listErrorPlaceholder(withMessage message: String) -> some View {
    VStack {
      Spacer()
      Text(message)
        .font(.headline)
        .multilineTextAlignment(.center)
      Spacer()
      Button(L10n.Localizable.fetchFailTryAgain) {
        self.model.fetch()
      }
      .fixedSize(horizontal: true, vertical: false)
    }
    .padding()
  }

  private func mainActionSheet(for device: BucketDevice) -> ActionSheet {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    let title =
      Text(device.name)
      + Text("\n\(L10n.Localizable.kwDeviceLastActive): ")
      + Text("\(device.lastUpdateDate, formatter: formatter)")

    return ActionSheet(
      title: title,
      buttons: [
        .default(
          Text(CoreL10n.kwDeviceRename),
          action: {
            self.deviceToBeRenamed = device
          }),
        .destructive(
          Text(L10n.Localizable.kwDeviceDeactivate),
          action: {
            DispatchQueue.main.async {
              self.deletionRequest = .singleItem(device)
            }
          }),
        .cancel(),
      ])
  }

  private func renameView(for device: BucketDevice) -> some View {
    DeviceRenameView(name: device.name) { completion in
      switch completion {
      case let .updated(name):
        Task {
          await self.model.rename(device, with: name)
        }
        fallthrough
      case .cancel:
        self.deviceToBeRenamed = nil
      }
    }
  }

  private func deactivateAlert(for mode: DeletionRequest) -> Alert {

    switch mode {
    case let .singleItem(device):
      return Alert(
        title: Text(L10n.Localizable.kwDeviceDeactivateTitleSingle),
        message: Text(L10n.Localizable.kwDeviceDeactivateMessage),
        primaryButton: .destructive(
          Text(L10n.Localizable.kwDeviceDeactivate),
          action: {
            Task {
              await self.model.deactivate([device])
            }
            self.selectedDevice = nil
            self.selectedDevices = []
          }),
        secondaryButton: .cancel())
    case let .multipleItems(devices):
      return Alert(
        title: Text(L10n.Localizable.kwDeviceDeactivateTitleMultiple(devices.count)),
        message: Text(L10n.Localizable.kwDeviceDeactivateMessage),
        primaryButton: .destructive(
          Text(L10n.Localizable.kwDeviceDeactivate),
          action: {
            Task {
              await self.model.deactivate(devices)
              self.selectedDevices = []
            }
          }),
        secondaryButton: .cancel())
    }

  }
}

extension BucketDevice: Identifiable {}

struct DevicesListView_Previews: PreviewProvider {
  typealias DevicesElement = UserDeviceAPIClient.Devices.ListDevices.Response.DevicesElement

  static let devices = [
    DevicesElement(
      id: "current",
      name: "iPhone",
      platform: .iphone,
      creationDate: Date(),
      lastUpdateDate: Date(),
      lastActivityDate: Date().addingTimeInterval(-300),
      isBucketOwner: false,
      isTemporary: false),
    DevicesElement(
      id: "idPixel",
      name: "Unsafe Device",
      platform: .android,
      creationDate: Date(),
      lastUpdateDate: Date(),
      lastActivityDate: Date().addingTimeInterval(-990000),
      isBucketOwner: false,
      isTemporary: false),
    DevicesElement(
      id: "idWin",
      name: "Windobe",
      platform: .windows,
      creationDate: Date(),
      lastUpdateDate: Date(),
      lastActivityDate: Date().addingTimeInterval(-990000),
      isBucketOwner: false,
      isTemporary: false),
    DevicesElement(
      id: "idWeb",
      name: "Slow Web",
      platform: .web,
      creationDate: Date(),
      lastUpdateDate: Date(),
      lastActivityDate: Date().addingTimeInterval(-1_990_000),
      isBucketOwner: false,
      isTemporary: false),
  ]

  static var previews: some View {
    Group {
      DevicesList(
        model: .init(
          userDeviceAPIClient: .mock({
            UserDeviceAPIClient.Devices.ListDevices.mock(.init(pairingGroups: [], devices: devices))
          }), currentDeviceId: "current",
          reachability: .mock()))

      DevicesList(
        model: .init(
          userDeviceAPIClient: .mock({
            UserDeviceAPIClient.Devices.ListDevices.mock { _, _ in
              throw URLError(.unknown)
            }
          }), currentDeviceId: "current",
          reachability: .mock(isConnected: false)))

      DevicesList(
        model: .init(
          userDeviceAPIClient: .mock({
            UserDeviceAPIClient.Devices.ListDevices.mock(.init(pairingGroups: [], devices: devices))
            UserDeviceAPIClient.Devices.DeactivateDevices.mock { _, _ in
              throw URLError(.unknown)
            }
          }), currentDeviceId: "current",
          reachability: .mock()))
    }

  }
}

extension DateGroup {
  fileprivate var localizedDeviceTitle: String {
    switch self {
    case .last24Hours:
      return L10n.Localizable.kwDeviceHeaderDay
    case .lastMonth:
      return L10n.Localizable.kwDeviceHeaderMonth
    case .lastYear:
      return L10n.Localizable.kwDeviceHeaderYear
    case .older:
      return L10n.Localizable.kwDeviceHeaderOlder
    }
  }
}
