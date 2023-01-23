import Foundation
import SwiftUI
import DocumentServices
import CoreUserTracking
import VaultKit
import UIDelight
import SwiftTreats

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

    init(model: AddAttachmentButtonViewModel,
         label: (() -> Label)? = nil) {
        self._model = .init(wrappedValue: model)
        self.label = label
    }

    var body: some View {
        content
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .imagePicker:
                    ImagePicker(imageData: self.$model.imageContent, sourceType: .photoLibrary)
                case .camera:
                    ImagePicker(imageData: self.$model.imageContent, sourceType: .camera)
                case .scanner:
                    DocumentScannerView(completion: model.saveScanImagesIntoPDF(result:))
                case .documentPicker:
                    DocumentPickerView(fileUrl: self.$model.fileUrl, supportedTypes: DocumentTypeSupport.supportedTypes)
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
                    .renameAlert(isPresented: $model.showRenameFile,
                                 filename: $model.filename) { filename in
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
                self.alertType = .upgradeToPremium { UIApplication.shared.open(URL(string: "dashlane:///getpremium")!) }
            }
        case .allowed:
            if Device.isMac {
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
            AddBarButton(action: action)
        }
    }

    @ViewBuilder
    private var nativeMenuActions: some View {
        Button(action: { self.sheet = .camera },
               title: L10n.Localizable.kwTakePhoto)
        Button(action: { self.sheet = .scanner },
               title: L10n.Localizable.scanDocuments)
        Button(action: { self.sheet = .imagePicker },
               title: L10n.Localizable.kwPickPhoto)
        Button(action: { self.sheet = .documentPicker },
               title: L10n.Localizable.kwPickFile)
    }

    private func alert(from alertType: AddAttachmentButtonViewModel.AlertType) -> Alert {
        if let secondaryButton = alertType.secondaryButton {
            return Alert(title: Text(alertType.title),
                  message: alertType.message,
                  primaryButton: alertType.primaryButton,
                  secondaryButton: secondaryButton)
        } else {
            return Alert(title: Text(alertType.title),
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
            case .upgradeToPremium: return L10n.Localizable.kwAttachPremiumTitle
            case .sharing: return L10n.Localizable.kwSharedItemNoAttachmentTitle
            case .error: return L10n.Localizable.kwErrorTitle
            }
        }

        var message: Text? {
            switch self {
            case .upgradeToPremium: return Text(L10n.Localizable.kwAttachPremiumMessage)
            case .sharing: return Text(L10n.Localizable.kwSharedItemNoAttachmentMessage)
            case .error(let message): return Text(message)
            }
        }

        var primaryButton: Alert.Button {
            switch self {
            case .upgradeToPremium(let action): return .default(Text(L10n.Localizable.goPremium), action: action)
            case .sharing: return .default(Text(L10n.Localizable.kwButtonOk))
            case .error: return .default(Text(L10n.Localizable.kwButtonOk))
            }
        }

        var secondaryButton: Alert.Button? {
            switch self {
            case .upgradeToPremium: return .cancel(Text(L10n.Localizable.cancel))
            default: return nil
            }
        }
    }

    enum SheetType: String, Identifiable {
        case imagePicker
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
