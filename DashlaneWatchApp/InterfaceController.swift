import Foundation
import WatchKit
import WatchConnectivity

final public class TokenRowController: NSObject {
    
    @IBOutlet var tokenLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var spinnerImage: WKInterfaceImage!
    
    
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
        let path = bundle.resourcePath! + String(format: "/%02d.png", index)
        let image = UIImage(contentsOfFile: path)
        cache[index] = image
        return image
    }
}

fileprivate extension String {
    var localized: String {
        return NSLocalizedString(self,
                                 tableName: "Watch",
                                 bundle: Bundle(for: InterfaceController.self),
                                 value: "",
                                 comment: "")
    }
    
    var groupedBy3: String {
        assert(self.count == 6)
        let first = self[startIndex ..< index(startIndex, offsetBy: 3)]
        let last = self[index(startIndex, offsetBy: 3) ..< endIndex]
        return "\(first) \(last)"
    }
}

final public class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var mainLabel: WKInterfaceLabel!
    @IBOutlet var tokensTable: WKInterfaceTable!
    
    private var session: WCSession?
    private var timer: Timer?
    private var spinner = Spinner()
    
    private var applicationContext: WatchApplicationContext! {
        didSet {
            tokensTable.setNumberOfRows(self.applicationContext.tokens.count, withRowType: "TokenRowController")
            updateTokens()
            updateCountDown()
            if self.applicationContext.tokens.isEmpty {
                sendFeedback(WatchFeedbackMessage(action: .messageSetupTotp))
            } else {
                sendFeedback(WatchFeedbackMessage(action: .totpCodeList))
            }
        }
    }
    
    override public func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        mainLabel.setText("WATCH_WELCOME_NO_TOKENS".localized)
        
        self.applicationContext = WatchApplicationContext()

                if let data = try? Data(contentsOf: storageURL) {
            if let context = try? JSONDecoder().decode(WatchApplicationContext.self, from: data) {
                self.applicationContext = context
            }
        }
        
                if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
        }
    }
    
    override public func willActivate() {
                super.willActivate()
        
        updateCountDown()
        startTimer()
        sendFeedback(WatchFeedbackMessage(action: .refreshContext))
    }
    
    override public func didDeactivate() {
                super.didDeactivate()
        
        stopTimer()
    }
    
    private var storageURL: URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsPath + "/applicationContext.json"
        return URL(fileURLWithPath: path)
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
    
    private var currentCounter = 0
    
    @objc func tic(timer: Timer) {
        updateCountDown()
        
        let info = TimeInfo()
        if info.counter != currentCounter {
            currentCounter = info.counter
            updateTokens()
        }
    }
    
    private func updateCountDown() {
        let info = TimeInfo()
        let image = spinner.getImage(index: info.remaining)
        for (index, _) in applicationContext.tokens.enumerated() {
            let row = tokensTable.rowController(at: index) as! TokenRowController
            row.spinnerImage.setImage(image)
        }
    }
    
    private func updateTokens() {
        mainLabel.setHidden(!applicationContext.tokens.isEmpty)
        
        let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        for (index, token) in applicationContext.tokens.enumerated() {
            guard let otpInfo = try? OTPConfiguration(otpURL: token.url) else {
                return
            }
            let otpCode = TOTPGenerator.generate(with: otpInfo.type, for: Date(), digits: otpInfo.digits, algorithm: otpInfo.algorithm, secret: otpInfo.secret, currentCounter: nil)
            let row = tokensTable.rowController(at: index) as! TokenRowController
            let monospacedString = NSAttributedString(string: otpCode.groupedBy3, attributes: [.font: monospacedFont])
            row.tokenLabel.setAttributedText(monospacedString)
            row.titleLabel.setText(token.title)
        }
    }
    
    
        private func sendFeedback(_ feedback: WatchFeedbackMessage) {
        do {
            let message = try feedback.toDict()
            session?.sendMessage(message, replyHandler: nil, errorHandler: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let newContext = try? WatchApplicationContext.fromDict(applicationContext) else { return }
        newContext.tokens.sort { $0.title < $1.title }
        
                if let data = try? JSONEncoder().encode(newContext) {
            try? data.write(to: storageURL, options: .completeFileProtection)
        }
        
                DispatchQueue.main.async {
            self.applicationContext = newContext
        }
    }
    
}

