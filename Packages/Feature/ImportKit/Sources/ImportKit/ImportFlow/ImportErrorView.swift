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

  let model: OldImportViewModel
  let action: @MainActor (Action) -> Void

  public var body: some View {
    VStack(alignment: .leading) {
      Spacer()

      DS.ExpressiveIcon(.ds.feedback.fail.outlined)
        .style(mood: .danger, intensity: .quiet)
        .controlSize(.large)
        .padding(.leading, 16)

      Spacer()
        .frame(height: 32)

      information

      Spacer()

      ctaButtons()

      Spacer()
        .frame(height: 30)
    }
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .navigationTitle(CoreL10n.m2WImportGenericImportScreenHeader)
    .documentPicker(open: model.kind.contentTypes, isPresented: $showDocumentPicker) { data in
      data.map { self.action(.importCompleted(data: $0)) }
    }
  }

  @ViewBuilder
  private func ctaButtons() -> some View {
    switch model.step {
    case .extract:
      Button(CoreL10n.m2WImportGenericImportErrorScreenBrowse) {
        self.showDocumentPicker = true
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 16)
    case .save:
      VStack {
        Button(CoreL10n.m2WImportGenericImportErrorScreenTryAgain) {
          self.save()
        }
        .buttonStyle(.designSystem(.titleOnly))

        Button(CoreL10n.m2WImportGenericImportErrorScreenBrowse) {
          self.showDocumentPicker = true
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(intensity: .supershy)
      }
      .padding(.horizontal, 16)
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
    return Text(CoreL10n.m2WImportGenericImportErrorScreenPrimaryTitle)
  }

  @ViewBuilder
  fileprivate var description: some View {
    switch model.step {
    case .extract:
      Text(CoreL10n.m2WImportGenericImportErrorScreenSecondaryTitle)
    case .save:
      Text(CoreL10n.m2WImportGenericImportErrorScreenGenericSecondaryTitle)
    }
  }

  fileprivate var styledTitle: some View {
    title
      .frame(maxWidth: 400, alignment: .leading)
      .textStyle(.title.section.large)
      .foregroundStyle(Color.ds.text.neutral.catchy)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 16)
  }

  fileprivate var styledDescription: some View {
    description
      .frame(maxWidth: 400, alignment: .leading)
      .font(.body.weight(.light))
      .foregroundStyle(Color.ds.text.neutral.standard)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 16)
  }

  fileprivate var styledHelpInfo: some View {
    Text(attributedHelpInfo)
      .frame(maxWidth: 400, alignment: .leading)
      .font(.body.weight(.light))
      .foregroundStyle(Color.ds.text.neutral.standard)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 16)
  }

}

extension ImportErrorView {

  fileprivate var attributedHelpInfo: AttributedString {
    let troubleshootString = CoreL10n.m2WImportGenericImportErrorScreenTroubleshootingLink
    let troubleshootURL = URL(string: "_")!
    let descriptionString = CoreL10n.m2WImportGenericImportErrorScreenTroubleshooting

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

#Preview {
  ImportErrorView(model: DashImportViewModel.mock) { _ in }
}
