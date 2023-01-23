import UIKit

final public class TokenCell: UITableViewCell {
    
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var spinnerImage: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!

    func showInfo(title: String, subtitle: String?) {
        let bundle = Bundle(for: MessageView.self)
        let banner = bundle.loadNibNamed("MessageView", owner: nil, options: nil)!.first as! MessageView
        banner.frame = self.bounds
        banner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        banner.backgroundColor = UIColor(red:0.13, green:0.71, blue:0.20, alpha:1.0) 
        banner.titleLabel.text = title
        banner.subtitleLabel.text = subtitle
        
        messageContainerView.addSubview(banner)
        messageContainerView.isHidden = false
        messageContainerView.superview?.layoutIfNeeded()

        let size = messageContainerView.bounds.size
        let slideIn = AnimationsCatalog.slideIn(direction: .fromBottom, containerSize: size)
        banner.layer.add(slideIn, forKey: "slideIn")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                banner.removeFromSuperview()
            })
            let slideOut = AnimationsCatalog.slideOut(direction: .fromBottom, containerSize: size)
            banner.layer.add(slideOut, forKey: "slideOut")
            CATransaction.commit()
        }
    }
    

}

