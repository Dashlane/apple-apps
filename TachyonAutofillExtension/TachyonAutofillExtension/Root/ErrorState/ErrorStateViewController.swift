import Foundation
import UIKit

protocol ErrorStateViewControllerDelegate: AnyObject {
    func close(_ errorStateViewController: ErrorStateViewController)
    func handleAction()
}

class ErrorStateViewController: UIViewController, InjectableViewController {

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var errorCodeLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    struct Input {
        let title: String
        let code: String
        let actionTitle: String
    }
    
    var input: Input!
    weak var delegate: ErrorStateViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTitle.text = input.title
        errorCodeLabel.text = "Code: \(input.code)"
        actionButton.setTitle(input.actionTitle, for: .normal)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        delegate?.close(self)
    }

    @IBAction func handleActionButtonTapped(_ sender: Any) {
        delegate?.handleAction()
    }
}
