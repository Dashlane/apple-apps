#if canImport(UIKit)

import UIKit
import SwiftUI

public extension View {

                        func activitySheet(_ item: Binding<ActivityItem?>,
                       permittedArrowDirections: UIPopoverArrowDirection = .any,
                       onComplete: UIActivityViewController.CompletionWithItemsHandler? = nil) -> some View {
        background(
            ActivityView(item: item,
                         permittedArrowDirections: permittedArrowDirections,
                         onComplete: onComplete)
        )
    }

}

private struct ActivityView: UIViewControllerRepresentable {

    @Binding var item: ActivityItem?
    private var permittedArrowDirections: UIPopoverArrowDirection
    private var completion: UIActivityViewController.CompletionWithItemsHandler?

    init(item: Binding<ActivityItem?>,
                permittedArrowDirections: UIPopoverArrowDirection,
                onComplete: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        _item = item
        self.permittedArrowDirections = permittedArrowDirections
        self.completion = onComplete
    }

    func makeUIViewController(context: Context) -> ActivityViewControllerWrapper {
        ActivityViewControllerWrapper(item: $item,
                                      permittedArrowDirections: permittedArrowDirections,
                                      completion: completion)
    }

    func updateUIViewController(_ controller: ActivityViewControllerWrapper, context: Context) {
        controller.item = $item
        controller.completion = completion
        controller.updateState(uiController: controller)
    }

}

private final class ActivityViewControllerWrapper: UIViewController {

    var item: Binding<ActivityItem?>
    var permittedArrowDirections: UIPopoverArrowDirection
    var completion: UIActivityViewController.CompletionWithItemsHandler?

    init(item: Binding<ActivityItem?>,
         permittedArrowDirections: UIPopoverArrowDirection,
         completion: UIActivityViewController.CompletionWithItemsHandler?) {
        self.item = item
        self.permittedArrowDirections = permittedArrowDirections
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func updateState(uiController: ActivityViewControllerWrapper) {
        guard item.wrappedValue != nil, uiController.presentedViewController == nil else {
            return
        }

        let controller = UIActivityViewController(activityItems: item.wrappedValue?.items ?? [], applicationActivities: item.wrappedValue?.activities)
        controller.excludedActivityTypes = item.wrappedValue?.excludedTypes
        controller.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        controller.popoverPresentationController?.sourceView = view
        controller.completionWithItemsHandler = { [weak self] (activityType, success, items, error) in
            self?.item.wrappedValue = nil
            self?.completion?(activityType, success, items, error)
        }
        present(controller, animated: true)
    }

}

public struct ActivityItem {

    internal var items: [Any]
    internal var activities: [UIActivity]?
    internal var excludedTypes: [UIActivity.ActivityType]

                        public init(items: Any..., activities: [UIActivity]? = nil, excludedTypes: [UIActivity.ActivityType] = []) {
        self.items = items
        self.activities = activities
        self.excludedTypes = excludedTypes
    }

}

#endif
