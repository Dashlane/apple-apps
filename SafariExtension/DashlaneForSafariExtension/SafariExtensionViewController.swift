import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width: 408, height: 560)
        return shared
    }()

    @IBOutlet weak var containerView: NSView!
    
    var contentViewController: NSViewController? {
        didSet {
            if let viewController = contentViewController, !children.contains(where: { $0 === viewController }) {
                addChild(viewController)
                
                if isViewLoaded {
                    setupContent(contentViewController: contentViewController,
                                 withPrevious: oldValue,
                                 containerView: containerView)
                }
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupContent(contentViewController: contentViewController,
                     withPrevious: nil,
                     containerView: containerView)
    }
}

extension NSViewController {
    func setupContent(contentViewController: NSViewController?,
                      withPrevious previousViewController: NSViewController?,
                      containerView: NSView) {
        guard let contentViewController = contentViewController else {
            return
        }

        if let previousVC = previousViewController {
            NSAnimationContext.runAnimationGroup {_ in
                transition(from: previousVC, to: contentViewController, options: .crossfade, completionHandler: nil)
                previousVC.removeFromParent()
                contentViewController.view.pinEdges(to: containerView)
            }
        } else if !containerView.subviews.contains(contentViewController.view) {
            containerView.addSubview(contentViewController.view)
            contentViewController.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
            contentViewController.view.pinEdges(to: containerView)
        }
    }
}

extension NSView {
    public func pinEdges(to other: NSView) {
        leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}

