import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

@MainActor
public struct ImportErrorView: View {

  public enum Action {
    case importCompleted(data: Data)
    case saved
  }

  @State
  private var showDocumentPicker: Bool = false

  let model: ImportViewModel
  let action: @MainActor (Action) -> Void

  public var body: some View {
    VStack(alignment: .leading) {
      Spacer()

      Image(asset: Asset.importError)
        .resizable()
        .frame(width: 96, height: 96)
        .padding(.leading, 16)

      Spacer()
        .frame(height: 32)

      information

      Spacer()

      ctaButtons()

      Spacer()
        .frame(height: 30)
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .navigationTitle(L10n.Core.m2WImportGenericImportScreenHeader)
    .navigationBarStyle(.transparent(tintColor: .ds.text.brand.standard, titleColor: nil))
    .documentPicker(open: model.kind.contentTypes, isPresented: $showDocumentPicker) { data in
      data.map { self.action(.importCompleted(data: $0)) }
    }
  }

  @ViewBuilder
  private func ctaButtons() -> some View {
    switch model.step {
    case .extract:
      Button(L10n.Core.m2WImportGenericImportErrorScreenBrowse) {
        self.showDocumentPicker = true
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 16)
    case .save:
      VStack {
        Button(L10n.Core.m2WImportGenericImportErrorScreenTryAgain) {
          self.save()
        }
        .buttonStyle(.designSystem(.titleOnly))
        .padding(.horizontal, 16)

        Button(L10n.Core.m2WImportGenericImportErrorScreenBrowse) {
          self.showDocumentPicker = true
        }
        .buttonStyle(BorderlessActionButtonStyle())
      }
    }
  }

  private func save() {
    Task {
      do {
        try await self.model.save(in: nil)
        await MainActor.run {
          self.action(.saved)
        }
      }
    }
  }

}

extension ImportErrorView {

  fileprivate var information: some View {
    VStack(alignment: .leading) {
      styledTitle
      Spacer()
        .frame(height: 8)
      styledDescription

      if case .extract = model.step {
        Spacer()
          .frame(height: 8)
        styledHelpInfo
      }
    }
  }

  fileprivate var title: some View {
    return Text(L10n.Core.m2WImportGenericImportErrorScreenPrimaryTitle)
  }

  @ViewBuilder
  fileprivate var description: some View {
    switch model.step {
    case .extract:
      Text(L10n.Core.m2WImportGenericImportErrorScreenSecondaryTitle)
    case .save:
      Text(L10n.Core.m2WImportGenericImportErrorScreenGenericSecondaryTitle)
    }
  }

  fileprivate var styledTitle: some View {
    title
      .frame(maxWidth: 400, alignment: .leading)
      .font(DashlaneFont.custom(28, .medium).font)
      .foregroundColor(.ds.text.neutral.catchy)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 16)
  }

  fileprivate var styledDescription: some View {
    description
      .frame(maxWidth: 400, alignment: .leading)
      .font(.body.weight(.light))
      .foregroundColor(.ds.text.neutral.standard)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 16)
  }

  fileprivate var styledHelpInfo: some View {
    Text(attributedHelpInfo)
      .frame(maxWidth: 400, alignment: .leading)
      .font(.body.weight(.light))
      .foregroundColor(.ds.text.neutral.standard)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 16)
  }

}

extension ImportErrorView {

  fileprivate var attributedHelpInfo: AttributedString {
    let troubleshootString = L10n.Core.m2WImportGenericImportErrorScreenTroubleshootingLink
    let troubleshootURL = URL(string: "_")!
    let descriptionString = L10n.Core.m2WImportGenericImportErrorScreenTroubleshooting

    return attributedString(
      for: descriptionString, hyperlinks: [troubleshootString: troubleshootURL])
  }

  private func attributedString(for string: String, hyperlinks: [String: URL]) -> AttributedString {
    var defaultAttributes = AttributeContainer()
    defaultAttributes.font = .system(.body).weight(.light)
    defaultAttributes.foregroundColor = .ds.text.brand.standard

    var attributedString = AttributedString(string, attributes: defaultAttributes)

    for (text, url) in hyperlinks {
      guard let range = attributedString.range(of: text) else { continue }
      attributedString[range].link = url
    }

    return attributedString
  }

}

struct ImportErrorView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(deviceRange: .some([.iPhone8, .iPhone11, .iPadPro])) {
      ImportErrorView(model: DashImportViewModel.mock, action: { _ in })
    }
  }
}
