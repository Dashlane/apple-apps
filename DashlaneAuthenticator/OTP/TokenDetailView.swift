import SwiftUI
import AuthenticatorKit
import DesignSystem
import CoreLocalization

struct TokenDetailView: View {

    @Environment(\.dismiss)
    var dismiss

    @StateObject
    var model: TokenDetailViewModel

    public init(model: @autoclosure @escaping () -> TokenDetailViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        ScrollView {
            mainView
        }.backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }

    var columns: [GridItem] {
        return [
            GridItem(.fixed(56), spacing: 16, alignment: .center),
            GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16, alignment: .leading),
            GridItem(.fixed(24))
        ]
    }

    var mainView: some View {
        VStack(spacing: 32) {
            LazyVGrid(columns: columns) {
                GeneratedOTPCodeRowView(model: model.makeGeneratedOTPCodeRowViewModel(),
                                        isEditing: false,
                                        hidesLeadingAction: true,
                                        performAction: model.tokenAction)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 34)
            .padding(.vertical, 16)
            .frame(height: 75)
            .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Color.ds.container.agnostic.neutral.supershy))
            TokenTextField(label: L10n.Localizable.editTokenTitleLabel.uppercased(), text: $model.title)
            TokenTextField(label: L10n.Localizable.editTokenWebsiteLabel.uppercased(), text: $model.issuer)
            TokenTextField(label: L10n.Localizable.editTokenLoginLabel.uppercased(), text: $model.email)

            Button(action: { model.showAlert = true }, label: {
                HStack {
                    Text(L10n.Localizable.editTokenDelete)
                    Spacer()
                }
                .foregroundColor(.ds.text.danger.standard)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Color.ds.container.agnostic.neutral.supershy))
            })
            Spacer()
        }.padding()
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        model.save()
                        dismiss()
                    }, title: L10n.Localizable.editSave)
                    .disabled(!model.canSave)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }, title: L10n.Localizable.buttonClose)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(L10n.Localizable.editTitle(model.token.configuration.title))
            .alert(Text(L10n.Localizable.otpDeletionTitle(model.token.configuration.issuerOrTitle)), isPresented: $model.showAlert) {
                Button(L10n.Localizable.otpDeletionConfirmButton, role: .destructive) {
                    model.delete()
                    dismiss()
                }
                Button(CoreLocalization.L10n.Core.cancel, role: .cancel) { }
            } message: {
                Text(L10n.Localizable.otpDeletionMessage(model.token.configuration.issuerOrTitle))
            }
    }
}

struct TokenDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TokenDetailView(model: TokenDetailViewModel(token: OTPInfo.mock, databaseService: AuthenticatorDatabaseServiceMock()) {_ in})
    }
}

struct TokenTextField: View {

    let label: String

    @Binding
    var text: String

    var body: some View {
        TextField("", text: $text)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Color.ds.container.agnostic.neutral.supershy))
            .labeled(label)
    }
}
