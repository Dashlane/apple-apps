import Foundation
import SwiftTreats
import SwiftUI
import UIKit

@available(iOS, introduced: 16, deprecated: 17.0, message: "Use searchable($isPresented) instead")
struct SearchBarIntrospectController: UIViewControllerRepresentable {
  private var isActive: Bool

  init(isActive: Bool) {
    self.isActive = isActive
  }

  func makeUIViewController(context: Context) -> SearchBarIntrospectViewController {
    SearchBarIntrospectViewController { searchBar in
      if let backgroundView = searchBar?.searchTextField.subviews.first?.subviews.first {
        backgroundView.isHidden = true
      }

      if let searchBar, let attributedPlaceholder = searchBar.searchTextField.attributedPlaceholder
      {
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
          string: attributedPlaceholder.string,
          attributes: [.foregroundColor: UIColor.ds.text.neutral.quiet]
        )
      }
    }
  }

  func updateUIViewController(_ viewController: SearchBarIntrospectViewController, context: Context)
  {
    guard viewController.searchBar?.searchTextField.isFirstResponder != isActive else { return }

    if isActive {
      DispatchQueue.main.async {
        viewController.searchBar?.searchTextField.becomeFirstResponder()
      }
    } else {
      DispatchQueue.main.async {
        viewController.searchBar?.searchTextField.resignFirstResponder()
      }
    }
  }
}

final class SearchBarIntrospectViewController: UIViewController {
  private(set) var searchBar: UISearchBar?
  private let didMoveToParentHandler: (UISearchBar?) -> Void

  init(didMoveToParentHandler: @escaping (UISearchBar?) -> Void) {
    self.didMoveToParentHandler = didMoveToParentHandler
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)

    var parentViewController = parent
    var finishedLookup = false

    if Device.isMac {
      repeat {
        if let navigationBar = parentViewController?.navigationController?.navigationBar {
          searchBar = navigationBar.firstSubview(matchingType: UISearchBar.self)
          finishedLookup = true
        } else {
          parentViewController = parentViewController?.parent
          finishedLookup = parentViewController == nil
        }
      } while !finishedLookup
    } else {
      repeat {
        if let searchController = parentViewController?.navigationItem.searchController {
          searchBar = searchController.searchBar
          finishedLookup = true
        } else {
          parentViewController = parentViewController?.parent
          finishedLookup = parentViewController == nil
        }
      } while !finishedLookup
    }

    didMoveToParentHandler(searchBar)
  }
}

extension UIView {

  fileprivate func firstSubview<T: UIView>(matchingType type: T.Type) -> T? {
    var subviews = self.subviews
    var finishedLookup = false

    repeat {
      guard !subviews.isEmpty else {
        finishedLookup = true
        continue
      }

      let lastSubview = subviews.removeFirst()

      if let subview = lastSubview as? T {
        return subview
      } else {
        subviews.append(contentsOf: lastSubview.subviews)
      }

    } while !finishedLookup

    return nil
  }
}
