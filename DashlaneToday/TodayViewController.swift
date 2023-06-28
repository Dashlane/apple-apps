import UIKit
import NotificationCenter
import MobileCoreServices
import TOTPGenerator

public protocol OTPGenerator: AnyObject {
    func generate(with info: OTPConfiguration) -> String
}

fileprivate struct TimeInfo {
    
    let time: Int 
    let counter: Int 
    let modulo: Int 
    let remaining: Int 
    
    init() {
        let now = Date().timeIntervalSince1970
        time = Int(round(now))
        counter = time / 30
        modulo = time % 30
        remaining = 30 - modulo
    }
}

fileprivate final class Spinner {
    
    private var cache = [UIImage?](repeating: nil, count: 31)
    
    func getImage(index: Int) -> UIImage? {
        if let image = cache[index] {
            return image
        }
        let bundle = Bundle(for: Spinner.self)
        let scale = Int(UIScreen.main.scale)
        let path = bundle.resourcePath! + String(format: "_", index, scale)
        let image = UIImage(contentsOfFile: path)
        cache[index] = image
        return image
    }
}

@available(iOS, deprecated: 14.0)
fileprivate extension String {
    var localized: String {
        return NSLocalizedString(self,
                                 tableName: "Today",
                                 bundle: Bundle(for: TodayViewController.self),
                                 value: "",
                                 comment: "")
    }
    
    var groupedBy3: String {
        assert(self.count == 6)
        let first = self[startIndex ..< index(startIndex, offsetBy: 3)]
        let last = self[index(startIndex, offsetBy: 3) ..< endIndex]
        return first + " " + last
    }
}

fileprivate class TokenUI {
    let url: URL
    let title: String
    let login: String
    let otpGenerator: OTPGenerator
    var code: String?
    
    init(from: TodayApplicationContext.Token, otpGenerator: OTPGenerator) {
        url = from.url
        title = from.title
        login = from.login
        self.otpGenerator = otpGenerator
    }
    
    func update() {
        guard let otpInfo = try? OTPConfiguration(otpURL: url) else {
            return
        }
        code = otpGenerator.generate(with: otpInfo)
    }
    
}

fileprivate enum HeaderMode {
    case hidden
    case isLocked
    case advancedSystemIntegration
    case noTokens
}

@available(iOS, deprecated: 14.0)
open class TodayViewController: UITableViewController, NCWidgetProviding {

    @IBOutlet var headerView: UIView!
    @IBOutlet var headerLabel: UILabel!
    public var context = TodayApplicationContext()
    private var timer: Timer?
    private let spinner = Spinner()
    private var spinnerImage: UIImage!
    private var tokens = [TokenUI]()
    private var headerMode = HeaderMode.hidden
    
    open weak var otpGenerationDelegate: OTPGenerator?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapHeader(_:)))
        headerView.addGestureRecognizer(gesture)

        FileProtectionUtility.isProtectedDataAvailable = {
                                    guard let containerURL = TodayApplicationContext.containerURL else { return false }
            let url = containerURL.appendingPathComponent("today.check", isDirectory: false)
            do {
                return try FileProtectionUtility.checkIfProtectedDataIsAvailable(at: url)
            } catch {
                print(error)
            }
            return false
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
        override open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell", for: indexPath) as! TokenCell
        let token = tokens[indexPath.row]
        
                cell.spinnerImage.image = spinnerImage

                cell.tokenLabel.text = token.code?.groupedBy3
        cell.titleLabel.text = token.title
        cell.loginLabel.text = token.login

        return cell
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TokenCell
        let token = tokens[indexPath.row]

        copyToClipboard(txt: token.code!)
        
        let title = "TODAY_COPIED_TO_CLIPBOARD".localized
        let subtitle = context.isUniversalClipboardEnabled ? "TODAY_ON_YOUR_IPHONE_AND_MAC".localized : nil
        cell.showInfo(title: title, subtitle: subtitle)
    }
    
    private func copyToClipboard(txt: String) {
        var options: [UIPasteboard.OptionsKey : Any] = [:]
        if context.isClipboardExpirationSet {
            let DashlanePasteboardExpirationTimeInterval: TimeInterval = 300
            let expirationDate = Date().addingTimeInterval(DashlanePasteboardExpirationTimeInterval)
            options[.expirationDate] = expirationDate
        }
        options[.localOnly] = !context.isUniversalClipboardEnabled
        UIPasteboard.general.setItems([[kUTTypeUTF8PlainText as String: txt]], options: options)
    }

    private func hideHeader() {
        tableView.tableHeaderView?.removeFromSuperview()
        tableView.tableHeaderView = nil
    }
    
    private func showHeader(txt: String) {
        headerLabel.text = txt
        tableView.tableHeaderView = headerView
    }
    
    @objc func tapHeader(_ sender: UITapGestureRecognizer) {
        switch headerMode {
        case .advancedSystemIntegration:
            openLink(key: "com.dashlane.linkForAdvancedSystemIntegration")
        case .noTokens:
            openLink(key: "com.dashlane.linkForAddToken")
        default:
            break
        }
    }
    
    private func openLink(key: String) {
        guard let info = Bundle.main.infoDictionary,
            let value = info[key] as? String,
            let url = URL(string: value) else { return }
        print("opening \(url)")
        extensionContext?.open(url)
    }
    
        
    public func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
                
                                updateContext()
        completionHandler(.newData)
    }
    
    public func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .expanded:
            let maxRows = Int(maxSize.height / tableView.rowHeight)
            let currentRows = tableView(tableView, numberOfRowsInSection: 0)
            let rows = min( maxRows, currentRows )
            preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(rows) * tableView.rowHeight)
        case .compact:
            preferredContentSize = maxSize
        @unknown default:
            preferredContentSize = maxSize
        }
    }
    
        
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tic), userInfo: nil, repeats: true)
        timer?.tolerance = 0.100 
        timer?.fireDate = Date(timeIntervalSince1970: ceil(Date().timeIntervalSince1970)) 
        timer?.fire()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    @objc func tic(timer: Timer) {
        FileProtectionUtility.shared.refreshProtectedDataAvailability()
        updateDisplay()
    }

    private func updateDisplay() {
        updateContext()
        updateTokens()
        updateCountDown()
        updateHeader()
        tableView.reloadData()
    }
    
    private func updateHeader() {
        if FileProtectionUtility.shared.lockState.isLocked() {
            headerMode = .isLocked
            showHeader(txt: "TODAY_IS_LOCKED".localized )
            extensionContext?.widgetLargestAvailableDisplayMode = .compact
        } else if context.advancedSystemIntegration == false {
            headerMode = .advancedSystemIntegration
            showHeader(txt: "TODAY_NEED_ADVANCED_SYSTEM_INTEGRATION".localized )
            extensionContext?.widgetLargestAvailableDisplayMode = .compact
        } else if tokens.isEmpty {
            headerMode = .noTokens
            showHeader(txt: "TODAY_WELCOME_NO_TOKENS".localized )
            extensionContext?.widgetLargestAvailableDisplayMode = .compact
        } else {
            headerMode = .hidden
            hideHeader()
            extensionContext?.widgetLargestAvailableDisplayMode = tokens.count > 2 ? .expanded : .compact
        }
    }

    private func updateCountDown() {
        let info = TimeInfo()
        spinnerImage = spinner.getImage(index: info.remaining)
    }
    
    private func updateTokens() {
        tokens.forEach { $0.update() }
    }
    
    open func updateContext() {
        var newContext = TodayApplicationContext()
        do {
            newContext = try TodayApplicationContext.fromDisk()
        } catch {
            print(error)
        }
        context = newContext
        guard let otpGenerator = otpGenerationDelegate else { return }
        tokens = context.tokens.map { TokenUI(from: $0, otpGenerator: otpGenerator) }
        sortTokens()
    }
    
    private func sortTokens() {
                tokens.sort {
            let titleOrder = $0.title.caseInsensitiveCompare( $1.title )
            if titleOrder == .orderedSame {
                let loginOrder = $0.login.caseInsensitiveCompare( $1.login )
                return loginOrder == .orderedAscending
            }
            return titleOrder == .orderedAscending
        }
    }
}

