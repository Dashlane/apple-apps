import Foundation
import SwiftUI
import TOTPGenerator

struct TOTPViewState {
  let code: String
  let progress: Double
}

struct TOTPView<Content: View>: View {
  let configuration: OTPConfiguration

  @ViewBuilder
  let content: (TOTPViewState) -> Content

  var body: some View {
    switch configuration.type {
    case .hotp:
      EmptyView()
    case .totp(let period):
      TimelineView(.periodic(from: Date(), by: 1)) { _ in
        let code = configuration.generate()
        let progress = TOTPGenerator.progress(in: period)

        content(.init(code: code, progress: progress))
          .animation(.default, value: code)
      }
    }
  }
}
