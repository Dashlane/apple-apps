import Foundation

@MainActor
class AddNewDeviceAlertViewModel: SessionServicesInjecting {

  let qrCode: String
  let addNewDeviceViewModelFactory: AddNewDeviceViewModel.Factory

  init(qrCode: String, addNewDeviceViewModelFactory: AddNewDeviceViewModel.Factory) {
    self.qrCode = qrCode
    self.addNewDeviceViewModelFactory = addNewDeviceViewModelFactory
  }

  func makeAddNewDeviceViewModel() -> AddNewDeviceViewModel {
    addNewDeviceViewModelFactory.make(qrCodeViaSystemCamera: qrCode)
  }
}
