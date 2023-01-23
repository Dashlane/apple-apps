import AVFoundation
import SwiftUI

#if !os(macOS)

public struct CodeScannerView: UIViewControllerRepresentable {
    public enum ScanError: Error {
        case badInput, badOutput, unknown
    }

    public class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CodeScannerView
        var canCompleteWithCodes: Bool = false
        
        init(parent: CodeScannerView) {
            self.parent = parent
        }

        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.last {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let code = readableObject.stringValue else {
                    didFail(reason: .unknown)
                    return
                }
                connection.isEnabled = false
                didFindCode(code)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    connection.isEnabled = true
                }
            }
        }

        func didFindCode(_ code: String) {
            guard canCompleteWithCodes else { return }
            parent.completion(.success(code))
        }

        func didFail(reason: ScanError) {
            parent.completion(.failure(reason))
        }
    }

    #if targetEnvironment(simulator)
    public class ScannerViewController: UIViewController {
        static let simulateData = "_"
        weak var delegate: ScannerCoordinator?

        override public func loadView() {
            view = UIView()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0

            label.text = "You're running in the simulator, which means the camera isn't available. Tap anywhere to send back some simulated data."
            label.textColor = .white
            view.addSubview(label)
            view.backgroundColor = .black
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                label.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
            ])
                        delegate?.canCompleteWithCodes = true
        }

        override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            delegate?.didFindCode(Self.simulateData)
        }
    }
    #else
    public class ScannerViewController: UIViewController {
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        weak var delegate: ScannerCoordinator?

        public override func viewDidLoad() {
            super.viewDidLoad()

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateOrientation),
                                                   name: UIDevice.orientationDidChangeNotification,
                                                   object: nil)

            view.backgroundColor = UIColor.black
            let captureSession = AVCaptureSession()
            self.captureSession = captureSession

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                delegate?.didFail(reason: .badInput)
                return
            }

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                delegate?.didFail(reason: .badInput)
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
            } else {
                delegate?.didFail(reason: .badOutput)
                return
            }

            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
        }

        public override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            previewLayer?.frame = view.layer.bounds
        }

        @objc func updateOrientation() {
            #if !EXTENSION

            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                return
            }
            let orientation = scene.interfaceOrientation
            guard let session = captureSession,
                  session.connections.count > 1  else {
                return
            }
            let previewConnection = captureSession?.connections[1]
            previewConnection?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
            #endif
        }

        public override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            updateOrientation()
                                                delegate?.canCompleteWithCodes = true
        }

        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if captureSession?.isRunning == false {
                captureSession?.startRunning()
            }
                        delegate?.canCompleteWithCodes = false
        }

        public override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if captureSession?.isRunning == true {
                captureSession?.stopRunning()
            }
        }
    }
    #endif

    let codeTypes: [AVMetadataObject.ObjectType]
    var completion: (Result<String, ScanError>) -> Void

    public init(codeTypes: [AVMetadataObject.ObjectType], completion: @escaping (Result<String, ScanError>) -> Void) {
        self.codeTypes = codeTypes
        self.completion = completion
    }

    public func makeCoordinator() -> ScannerCoordinator {
        return ScannerCoordinator(parent: self)
    }

    public func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {

    }
}

struct CodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CodeScannerView(codeTypes: [.qr]) { _ in
                    }
    }
}
#endif
