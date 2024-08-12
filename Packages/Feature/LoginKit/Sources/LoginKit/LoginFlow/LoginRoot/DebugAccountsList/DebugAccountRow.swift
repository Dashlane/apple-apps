import CoreSession
import DashTypes
import DesignSystem
import SwiftUI

struct DebugAccountRow: View {
  let accountInfo: AccountInfo

  var body: some View {
    VStack {
      HStack {
        Text(accountInfo.email)
          .font(.body.weight(.medium))
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      if let subtitle = accountInfo.subtitle {
        DebugAccountSubtitle(
          image: accountInfo.loginType.image,
          subtitle: subtitle)
      }
    }
  }
}

private struct DebugAccountSubtitle: View {
  let image: ImageAsset?
  let subtitle: String

  var body: some View {
    HStack {
      if let image = image {
        Image(asset: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 20)
      }
      Text(subtitle)
        .font(.footnote)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .foregroundColor(.ds.text.neutral.quiet)
  }
}

extension LoginType {
  var image: ImageAsset? {
    switch self {
    case .masterPassword:
      return nil
    case .sso:
      return Asset.sso
    case .otp:
      return Asset._2fa
    }
  }

  var subtitle: String? {
    switch self {
    case .masterPassword:
      return nil
    case .sso:
      return "SSO"
    case .otp(let otpType):
      switch otpType {
      case .duoPush:
        return "OTP - DuoPush"
      case .otp2:
        return "OTP2"
      case .otp1:
        return "OTP1"
      }
    }
  }
}
