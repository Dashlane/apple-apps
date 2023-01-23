import SwiftUI

public extension RoundedButton where Content == RoundedButtonIconContentView {
                    init(icon: Image, action: @escaping () -> Void) {
        self.init(action: action) {
            RoundedButtonIconContentView(icon: icon)
        }
    }
}

public extension RoundedButton where Content == RoundedButtonTitleContentView {
                    init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) {
        self.init(action: action) {
            RoundedButtonTitleContentView(label: Text(titleKey))
        }
    }

                                            init<S: StringProtocol>(_ title: S, action: @escaping () -> Void) {
        self.init(action: action) {
            RoundedButtonTitleContentView(label: Text(title))
        }
    }
}

public extension RoundedButton where Content == RoundedButtonTitleIconContentView {
                        init(_ titleKey: LocalizedStringKey, icon: Image, action: @escaping () -> Void) {
        self.init(action: action) {
            RoundedButtonTitleIconContentView(label: Text(titleKey), icon: icon)
        }
    }

                        init<S: StringProtocol>(_ title: S, icon: Image, action: @escaping () -> Void) {
        self.init(action: action) {
            RoundedButtonTitleIconContentView(label: Text(title), icon: icon)
        }
    }
}
