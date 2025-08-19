import CoreLocalization
import DocumentServices
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

struct AddAttachmentButton<Label: View>: View {
  @StateObject
  var model: AddAttachmentButtonViewModel

  @State
  private var sheet: AddAttachmentButtonViewModel.SheetType?

  @State
  private var alertType: AddAttachmentButtonViewModel.AlertType? {
    didSet {
      if alertType == nil {
        self.model.error = nil
      }
    }
  }

  let label: (() -> Label)?

  init(
    model: AddAttachmentButtonViewModel,
    label: (() -> Label)? = nil
  ) {
    self._model = .init(wrappedValue: model)
    self.label = label
  }

  var body: some View {
    content
      .sheet(item: $sheet) { sheet in
        switch sheet {
        case .imagePicker:
          ImagePicker(imageData: self.$model.imageContent, sourceType: .photoLibrary)
        #if !os(visionOS)
          case .camera:
            ImagePicker(imageData: self.$model.imageContent, sourceType: .camera)
        #endif
        case .scanner:
          DocumentScannerView(completion: model.saveScanImagesIntoPDF(result:))
        case .documentPicker:
          DocumentPickerView(
            fileUrl: self.$model.fileUrl, supportedTypes: DocumentTypeSupport.supportedTypes)
        }
      }
      .onReceive(model.$error.receive(on: DispatchQueue.main)) { error in
        if let error = error {
          self.alertType = .error(message: error.localizedDescription)
        }
      }
      .background {
        EmptyView().alert(item: $alertType, content: alert(from:))
      }
      .background {
        EmptyView()
          .renameAlert(
            isPresented: $model.showRenameFile,
            filename: $model.filename
          ) { filename in
            self.model.saveNewFile(with: filename)
          }
      }
  }

  @ViewBuilder
  private var content: some View {
    switch model.addAttachmentPermission {
    case .notAllowedItemIsShared:
      button {
        self.alertType = .sharing
      }
    case .notAllowedNeedsToUpgradePlan:
      button {
        self.alertType = .upgradeToPremium {
          UIApplication.shared.open(URL(string: "dashlane:///getpremium")!)
        }
      }
    case .allowed:
      if Device.is(.mac) {
        button {
          self.sheet = .documentPicker
        }
      } else {
        Menu {
          nativeMenuActions
        } label: {
          button {}
        }
      }
    }
  }

  @ViewBuilder
  private func button(_ action: @escaping () -> Void) -> some View {
    if let label = label {
      Button(action: action, label: label)
    } else {
      Button(action: action) {
        Image(systemName: "plus")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 18, height: 18)
          .foregroundStyle(Color.ds.text.brand.standard)
          .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0))
          .contentShape(Rectangle())
      }
    }
  }

  @ViewBuilder
  private var nativeMenuActions: some View {
    #if !os(visionOS)
      Button(CoreL10n.kwTakePhoto) {
        self.sheet = .camera
      }
    #endif
    Button(CoreL10n.scanDocuments) {
      self.sheet = .scanner
    }
    Button(CoreL10n.kwPickPhoto) {
      self.sheet = .imagePicker
    }
    Button(CoreL10n.kwPickFile) {
      self.sheet = .documentPicker
    }
  }

  private func alert(from alertType: AddAttachmentButtonViewModel.AlertType) -> Alert {
    if let secondaryButton = alertType.secondaryButton {
      return Alert(
        title: Text(alertType.title),
        message: alertType.message,
        primaryButton: alertType.primaryButton,
        secondaryButton: secondaryButton)
    } else {
      return Alert(
        title: Text(alertType.title),
        message: alertType.message,
        dismissButton: alertType.primaryButton)
    }
  }
}

extension AddAttachmentButtonViewModel {
  enum AlertType: Identifiable {
    case sharing
    case upgradeToPremium(action: () -> Void)
    case error(message: String)

    var id: String {
      switch self {
      case .upgradeToPremium: return "upgradeToPremium"
      case .sharing: return "sharing"
      case .error: return "error"
      }
    }

    var title: String {
      switch self {
      case .upgradeToPremium: return CoreL10n.kwAttachPremiumTitle
      case .sharing: return CoreL10n.kwSharedItemNoAttachmentTitle
      case .error: return CoreL10n.kwErrorTitle
      }
    }

    var message: Text? {
      switch self {
      case .upgradeToPremium: return Text(CoreL10n.kwAttachPremiumMessage)
      case .sharing: return Text(CoreL10n.kwSharedItemNoAttachmentMessage)
      case .error(let message): return Text(message)
      }
    }

    var primaryButton: Alert.Button {
      switch self {
      case .upgradeToPremium(let action): return .default(Text(CoreL10n.goPremium), action: action)
      case .sharing: return .default(Text(CoreL10n.kwButtonOk))
      case .error: return .default(Text(CoreL10n.kwButtonOk))
      }
    }

    var secondaryButton: Alert.Button? {
      switch self {
      case .upgradeToPremium: return .cancel(Text(CoreL10n.cancel))
      default: return nil
      }
    }
  }

  enum SheetType: String, Identifiable {
    case imagePicker
    @available(visionOS, unavailable)
    case camera
    case scanner
    case documentPicker

    var id: String {
      return rawValue
    }
  }
}

extension AddAttachmentButton where Label == EmptyView {
  init(model: AddAttachmentButtonViewModel) {
    self.init(model: model, label: nil)
  }
}
