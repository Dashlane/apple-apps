import SwiftUI

struct UserGroupIcon: View {
    var body: some View {
        Image(asset: FiberAsset.userGroup)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct UserGroupIcon_Previews: PreviewProvider {
    static var previews: some View {
        UserGroupIcon()
            .contactsIconStyle(isLarge: false)
        UserGroupIcon()
            .contactsIconStyle(isLarge: true)
    }
}
