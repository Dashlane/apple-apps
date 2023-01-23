import SwiftUI
import CorePersonalData
import Combine
import UIDelight
import DashlaneAppKit
import IconLibrary
import VaultKit

struct CredentialRowView<Model: CredentialRowViewModelProtocol>: View {
    @ObservedObject
    var model: Model

    let select: () -> Void
    
    init(model: Model,
         select: @escaping () -> Void) {
        self.model = model
        self.select = select
    }

    var body: some View {
        HStack(spacing: 16) {
            main
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowBackground(Color(asset: FiberAsset.systemBackground))
    }

    private var main: some View {
        HStack(spacing: 16) {
            VaultItemIconView(isListStyle: true, model: model.makeVaultItemIconViewModel())
            VStack(alignment: .leading, spacing: 4) {
                ItemRowInfoView(item: model.item, highlightedString: model.highlightedString, type: .title)
                ItemRowInfoView(item: model.item, highlightedString: model.highlightedString, type: .subtitle)
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapWithFeedback(perform: select)
    }

}

struct CredentialRowView_Previews: PreviewProvider {
    class Model : CredentialRowViewModelProtocol {
        var item: VaultItem {
            PersonalDataMock.Credentials.youtube
        }

        var highlightedString: String? = nil

        func makeVaultItemIconViewModel() -> VaultItemIconViewModel {
            return VaultItemIconViewModel.mock(item: item)
        }
    }

    static var previews: some View {
        MultiContextPreview {
            List {
                CredentialRowView(model: mockModel) {}
            }
        }.previewLayout(.sizeThatFits)
    }


    static var mockModel: Model {
        return Model()
    }


}
