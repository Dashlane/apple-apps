import CoreLocalization
import DashlaneAppKit
import DesignSystem
import SwiftUI
import UIDelight
import UIComponents
import VaultKit

public struct ImportListView<Model>: View where Model: ObservableObject, Model: ImportViewModel {

    public enum Action {
        case saved
        case savingError
    }

    @ObservedObject
    var model: Model

    let action: (Action) -> Void

    public var body: some View {
        VStack {
            title
            passwordList
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .navigationBarStyle(.transparent(tintColor: .ds.text.brand.standard, titleColor: nil))
        .overlay(importButton, alignment: .bottom)
    }

    private var title: some View {
        Text(L10n.Core.m2WImportGenericImportScreenPrimaryTitle(model.items.count))
            .frame(maxWidth: 400, alignment: .leading)
            .font(DashlaneFont.custom(28, .medium).font)
            .foregroundColor(.ds.text.neutral.catchy)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var passwordList: some View {
        ScrollView {
            ForEach(model.items) { item in
                ImportItemRowView(item: item, iconViewModel: .init(item: item.vaultItem, iconService: model.iconService))
            }
            .padding(.leading, 16)
            .padding(.trailing, 24)

            Spacer()
                .frame(minHeight: 84)
        }
    }

    private var importButton: some View {
        RoundedButton(L10n.Core.m2WImportGenericImportScreenImport,
                      action: save)
        .roundedButtonLayout(.fill)
        .roundedButtonDisplayProgressIndicator(model.inProgress)
        .disabled(model.inProgress || !model.isAnyItemSelected)
        .padding(.horizontal, 16)
        .padding(.vertical, 26)
    }

    private func save() {
        Task {
            do {
                try await self.model.save()
                await MainActor.run {
                    self.action(.saved)
                }
            } catch {
                await MainActor.run {
                    self.action(.savingError)
                }
            }
        }
    }

}

private struct ImportItemRowView: View {

    @ObservedObject
    var item: ImportItem

    let iconViewModel: VaultItemIconViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VaultItemIconView(isListStyle: true, model: iconViewModel)
                .padding(.trailing, 16)

            VStack(alignment: .leading) {
                Text(item.vaultItem.localizedTitle)
                    .font(.body.weight(.medium))
                    .foregroundColor(.ds.text.neutral.catchy)
                    .lineLimit(1)

                Spacer()
                    .frame(height: 1)

                Text(item.vaultItem.localizedSubtitle)
                    .font(.footnote)
                    .foregroundColor(.ds.text.neutral.quiet)
                    .lineLimit(1)
            }
            .padding(.vertical, 10)

            Spacer()

            if item.isSelected {
                Image(asset: Asset.checkboxSelected)
                    .resizable()
                    .frame(width: 24, height: 24)
            } else {
                Image(asset: Asset.checkboxUnselected)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .background(.ds.background.alternate)
        .onTapGesture {
            item.isSelected.toggle()
        }
        .fiberAccessibilityElement(children: .combine)
    }

}

struct ImportListView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhone8, .iPhone11, .iPadPro])) {
            ImportListView(model: DashImportViewModel.mock, action: { _ in })
        }
    }
}
