import UIKit
import SwiftUI
import DashlaneAppKit
import SwiftTreats
import DesignSystem

private struct SidebarContentConfiguration: UIContentConfiguration, Hashable {
    enum SecondaryLabel: Hashable {
        case text(String)
        case badge(BadgeConfiguration)
    }

    let title: String
    private let image: UIImage?
    private let selectedImage: UIImage?
    let isSelected: Bool

    let childConfiguration: UIListContentConfiguration
    let secondaryLabel: SecondaryLabel?

    init(title: String,
         image: UIImage?,
         selectedImage: UIImage?,
         secondaryLabel: SecondaryLabel? = nil,
         childConfiguration: UIListContentConfiguration = Self.makeChildConfiguration(),
         isSelected: Bool) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.isSelected = isSelected
        self.childConfiguration = childConfiguration
        self.secondaryLabel = secondaryLabel
    }

    func makeContentView() -> UIView & UIContentView {
        SidebarContentView(self)
    }

    func updated(for state: UIConfigurationState) -> SidebarContentConfiguration {
        guard let cellState = state as? UICellConfigurationState else { return self }

        var updatedChildConfiguration = childConfiguration.updated(for: state)
        updatedChildConfiguration.text = title

        if cellState.isSelected {
            let tintColor = UIColor.ds.text.neutral.catchy
            updatedChildConfiguration.imageProperties.tintColor = tintColor
            updatedChildConfiguration.textProperties.color = tintColor
            updatedChildConfiguration.image = selectedImage?.withTintColor(tintColor)
        } else {
            let tintColor = UIColor.ds.text.neutral.standard
            updatedChildConfiguration.image = image
            updatedChildConfiguration.imageProperties.tintColor = tintColor
            updatedChildConfiguration.textProperties.color = tintColor
        }

        return SidebarContentConfiguration(
            title: title,
            image: image,
            selectedImage: selectedImage,
            secondaryLabel: secondaryLabel,
            childConfiguration: updatedChildConfiguration,
            isSelected: cellState.isSelected
        )
    }

    private static func makeChildConfiguration() -> UIListContentConfiguration {
        var systemConfiguration = UIListContentConfiguration.sidebarCell()

        systemConfiguration.imageProperties.maximumSize = .init(width: 24, height: 24)
        if Device.isMac {
            systemConfiguration.imageProperties.reservedLayoutSize = .init(width: 30, height: 44)
        } else {
            systemConfiguration.imageProperties.reservedLayoutSize = .init(width: 30, height: 24)
        }
        systemConfiguration.prefersSideBySideTextAndSecondaryText = true
        systemConfiguration.secondaryTextProperties.font = systemConfiguration.secondaryTextProperties.font.withSize(17)

        return systemConfiguration
    }
}

private final class SidebarContentView: UIStackView, UIContentView {
    private let systemContentView: UIView & UIContentView
    private var badgeView: UIView?

    private var appliedConfiguration: SidebarContentConfiguration!

    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfiguration = newValue as? SidebarContentConfiguration else { return }
            applyConfiguration(newConfiguration)
        }
    }

    init(_ configuration: SidebarContentConfiguration) {
        systemContentView = configuration.childConfiguration.makeContentView()
        super.init(frame: .zero)

        setupAccessibility(configuration)

        axis = .horizontal
        spacing = 8
        distribution = .fill
        alignment = .center
        directionalLayoutMargins.trailing = 8
        isLayoutMarginsRelativeArrangement = true

        systemContentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addArrangedSubview(systemContentView)
        applyConfiguration(configuration)
    }

    private func setupAccessibility(_ configuration: SidebarContentConfiguration) {

        isAccessibilityElement = true
        if let secondary = configuration.secondaryLabel {
            switch secondary {
            case let .text(text):
                accessibilityLabel = "\(configuration.title), \(text)"
            case let .badge(badge):
                accessibilityLabel = "\(configuration.title), \(badge.title)"
            }
        } else {
            accessibilityLabel = configuration.title
        }
        accessibilityIdentifier = configuration.title
        accessibilityTraits = .button
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyConfiguration(_ configuration: SidebarContentConfiguration) {
        guard configuration != appliedConfiguration else { return }

        appliedConfiguration = configuration
        systemContentView.configuration = configuration.childConfiguration
        switch configuration.secondaryLabel {
        case let .badge(configuration):
            addBadgeView(with: configuration)
        case let .text(text):
            if configuration.isSelected {
                addSecondaryTextView(with: text, foregroundColor: .ds.text.neutral.catchy)
            } else {
                addSecondaryTextView(with: text, foregroundColor: .ds.text.neutral.quiet)
            }
        default:
            break
        }
    }

    private func addBadgeView(with configuration: BadgeConfiguration?) {
        badgeView?.removeFromSuperview()

        guard let configuration = configuration,
            let badgeView = UIHostingController(rootView:
                Badge(configuration.title)
                    .style(mood: .neutral, intensity: .quiet)
                    .accessibilityLabel(Text(configuration.accessibilityLabel))
            ).view
        else { return }

        badgeView.backgroundColor = .clear
        badgeView.setContentHuggingPriority(.required, for: .horizontal)
        badgeView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        self.badgeView = badgeView

        addArrangedSubview(badgeView)
    }

    private func addSecondaryTextView(with text: String, foregroundColor: Color) {
        badgeView?.removeFromSuperview()

        let textView = Text(text)
            .foregroundColor(foregroundColor)

        guard let badgeView = UIHostingController(rootView: textView).view
        else { return }

        badgeView.backgroundColor = .clear
        badgeView.setContentHuggingPriority(.required, for: .horizontal)
        badgeView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        self.badgeView = badgeView

        addArrangedSubview(badgeView)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        return CGSize(width: targetSize.width, height: size.height)
    }
}

final class SidebarCollectionCell: UICollectionViewCell {

    var item: SidebarItem? {
        didSet { setNeedsUpdateConfiguration() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundConfiguration = UIBackgroundConfiguration.listSidebarCell()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)

                var backgroundConfig = UIBackgroundConfiguration.listSidebarCell().updated(for: state)
        backgroundConfig.backgroundColor = state.isSelected ? .ds.container.expressive.neutral.supershy.active : .clear
        backgroundConfig.cornerRadius = 10
        backgroundConfig.backgroundInsets = .init(top: 1, leading: 0, bottom: 1, trailing: 0)
        backgroundConfiguration = backgroundConfig

                guard let item = item else { return }
        let secondaryLabel = item.detail?.secondaryLabel
        let contentConfiguration = SidebarContentConfiguration(
            title: item.title,
            image: item.image,
            selectedImage: item.selectedImage,
            secondaryLabel: secondaryLabel,
            isSelected: false
        )
        self.contentConfiguration = contentConfiguration
    }
}

private extension TabElementDetail {
    var secondaryLabel: SidebarContentConfiguration.SecondaryLabel? {
        switch self {
        case let .badge(configuration):
            return .badge(configuration)
        case let .text(text):
            return .text(text)
        }
    }
}
