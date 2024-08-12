import SwiftUI

struct WatchTokenRow: View {
  @StateObject var viewModel: WatchTokenRowViewModel

  init(token: WatchApplicationContext.Token) {
    self._viewModel = .init(wrappedValue: .init(token: token))
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(viewModel.code)
          .font(.system(size: 20))
          .padding(.horizontal, 5)
        Text(viewModel.issuer)
          .font(.system(size: 11))
          .foregroundColor(.white.opacity(0.8))
          .padding(.horizontal, 5)
      }

      Spacer()

      if let otpConfig = viewModel.otpConfiguration,
        case let .totp(period) = otpConfig.type
      {
        TOTPView(
          code: $viewModel.code,
          token: otpConfig,
          period: period
        )
      }
    }
  }
}

struct WatchTokenRow_Previews: PreviewProvider {
  static var previews: some View {
    List {
      WatchTokenRow(token: .mockGoogle)
      WatchTokenRow(token: .mockGoogle)
      WatchTokenRow(token: .mockGoogle)
    }
  }
}
