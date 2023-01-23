import Foundation
import SwiftUI
import CoreSync
import Combine
import UIDelight
import DashlaneAppKit
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
        .listRowBackground(Color(asset: AuthenticatorAsset.systemBackground))
    }

    private var main: some View {
        HStack(spacing: 16) {
            CredentialItemIconView(model: model.makeIconViewModel()).equatable()
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                ItemRowInfoView(item: model.item, highlightedString: nil, type: .title)
                ItemRowInfoView(item: model.item, highlightedString: nil, type: .subtitle)
                    .font(.footnote)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.ds.text.neutral.catchy)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapWithFeedback(perform: select)
        .background(.ds.container.agnostic.neutral.supershy)
        .cornerRadius(4)
    }

}

struct CredentialRowView_Previews: PreviewProvider {
    class Model : CredentialRowViewModelProtocol {
        var item: VaultItem {
            PersonalDataMock.Credentials.youtube
        }

        var highlightedString: String? = nil

        func makeIconViewModel() -> VaultItemIconViewModel {
            return VaultItemIconViewModel.mock(item: item)
        }
    }

    static var previews: some View {
        MultiContextPreview {
            
                CredentialRowView(model: mockModel) {}
                .padding(20)
                .background(Color.red)
        }.previewLayout(.sizeThatFits)
    }


    static var mockModel: Model {
        return Model()
    }


}
