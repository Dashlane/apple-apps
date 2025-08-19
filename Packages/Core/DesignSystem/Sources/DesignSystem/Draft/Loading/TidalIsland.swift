import SwiftUI

extension DS.Draft {
  struct TidalIsland<Content: View>: View {
    @ViewBuilder
    var content: () -> Content

    @State
    var isVisisble = false

    var body: some View {
      content()
        .padding(35)
        .background(Color.ds.container.agnostic.inverse.standard, in: .containerRelative)
        .controlSize(.large)
        .shadow(color: .black.opacity(0.3), radius: 50, x: 0, y: 20)
        .containerShape(RoundedRectangle(cornerRadius: 42))
    }
  }
}

#Preview("Tidal Island") {
  VStack {
    DS.Draft.TidalIsland {
      ProgressView()
        .progressViewStyle(IndeterminateProgressViewStyle(invertColors: true))
    }

    Spacer()
  }

}
