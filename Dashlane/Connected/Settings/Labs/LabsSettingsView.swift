import CoreFeature
import DesignSystem
import SwiftUI

struct LabsSettingsView: View {

  @StateObject
  var model: LabsSettingsViewModel

  public init(viewModel: @autoclosure @escaping () -> LabsSettingsViewModel) {
    self._model = .init(wrappedValue: viewModel())
  }

  var body: some View {
    List {
      VStack(alignment: .leading) {
        Text("Welcome to Dashlane Labs")
          .textStyle(.title.block.medium)
          .padding(.bottom, 8)

        Text(
          "This is where you can test early features before we roll them out to everyone. Let us know what you think of them!"
        )
        .textStyle(.body.standard.regular)
        .padding(.bottom, 8)

        Button(L10n.Localizable.internalDashlaneLabsInfoFeedbackCta) {
          model.goToFeedbackForm()
        }
        .buttonStyle(.externalLink)
        .controlSize(.small)

      }
      .padding(.vertical, 8)

      Section {
        Infobox("Modifications will apply onyl after you restart the app.")
          .style(.warning)
          .listRowInsets(EdgeInsets())
      } header: {
        Text("Ongoing experiments")
      }

      ForEach($model.experiences) { experience in
        experienceView(experience)
      }

    }
    .listAppearance(.insetGrouped)
    .background(Color.ds.background.alternate.ignoresSafeArea(.container))
    .navigationTitle(L10n.Localizable.internalDashlaneLabsTitle)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar(.hidden, for: .tabBar)
    .task {
      await model.fetch()
    }
  }

  @ViewBuilder
  func experienceView(_ experience: Binding<LabsExperience>) -> some View {
    VStack(alignment: .leading, spacing: 20) {
      DS.Toggle(isOn: experience.isOn) {
        Text(experience.wrappedValue.displayName)
          .textStyle(.title.block.medium)
      }

      Text(experience.wrappedValue.displayDescription)
        .textStyle(.body.reduced.regular)
    }
    .padding(.vertical, 8)
  }
}

struct LabsSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      let viewModel = LabsSettingsViewModel.mock
      LabsSettingsView(viewModel: viewModel)
    }

  }
}
